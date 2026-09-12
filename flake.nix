{
  description = "k8s calculator - solve 'multiply two numbers using Kubernetes' with hype technologies";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # 1. Define the package list
        tools = with pkgs; [
          kubectl
          kind
          kubernetes-helm
          docker
          docker-compose
          rootlesskit
          gnumake
          git
          curl
          bc
          yq
          jq
        ];

        # 2. Bundle all packages into a single Nix store path
        k8sToolsEnv = pkgs.buildEnv {
          name = "k8s-calc-tools";
          paths = tools;
          pathsToLink = [ "/bin" "/share" ]; # Merges bin/ and man/completions into this store path
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [ k8sToolsEnv ];
          shellHook = ''

            # Create a localized runtime directory for the isolated socket
            export XDG_RUNTIME_DIR="$PWD/.runtime"
            mkdir -p "$XDG_RUNTIME_DIR"

            # store all helm/kind/docker cache in same dir
            export KUBECONFIG=$XDG_RUNTIME_DIR/kube
            export XDG_CACHE_HOME=$XDG_RUNTIME_DIR/cache
            export XDG_DATA_HOME=$XDG_RUNTIME_DIR/data
            export XDG_CONFIG_HOME=$XDG_RUNTIME_DIR
            export HELM_HOME=$XDG_RUNTIME_DIR/helm
            export HELM_DATA_HOME=$XDG_RUNTIME_DIR/helm
            export HELM_CACHE_HOME=$XDG_RUNTIME_DIR/helm/cache

            # Point the docker client to the localized rootless socket
            export DOCKER_HOST="unix://$XDG_RUNTIME_DIR/docker.sock"
            echo -e "🚀 Starting isolated rootless dockerd...\n"
            # redirect its logs to a file so it doesn't block the shell
            dockerd-rootless > "$XDG_RUNTIME_DIR/dockerd.log" 2>&1 &
            DOCKER_PID=$!

            # Wait a brief moment for the socket file to actually be created
            while [ ! -S "$XDG_RUNTIME_DIR/docker.sock" ]; do
              sleep 0.2
            done

            stop_docker() {
              echo "Stopping Docker daemon..."
              if kill -0 $DOCKER_PID; then
                kill $DOCKER_PID
                wait $DOCKER_PID
              fi
            }

            k8_calc_cleanup() {
              echo -e "\n🧹 Cleaning up environment..."

              stop_docker

              echo "Cleaning up files..."
              rootlesskit rm -rf "$XDG_RUNTIME_DIR" 2>/dev/null || rm -rf "$XDG_RUNTIME_DIR"

              echo "✨ All clear! Goodbye."
            }
            trap stop_docker EXIT

            k8_calc_deploy() {
              kind create cluster --config=./kind.yaml && \
              kubectl kustomize "https://github.com/nginx/nginx-gateway-fabric/config/crd/gateway-api/standard?ref=v2.7.0" | kubectl apply -f - && \
              helm install ngf oci://ghcr.io/nginx/charts/nginx-gateway-fabric --create-namespace -n nginx-gateway && \
              helm install k8-calc k8-calc/
            }

            k8_calc_recalc() {
              helm upgrade k8-calc k8-calc/ --set expression=$1
              kubectl delete job bc
              kubectl apply -f k8-calc/templates/bc-deployment.yaml
              sleep 2

              ATTEMPT=1
              MAX_ATTEMPTS=10
              while [[ $ATTEMPT -le $MAX_ATTEMPTS ]]; do
                  ANSWER=$(curl localhost:30080/k8_calc)

                  if [ -n "$ANSWER" ]; then
                      break
                  fi

                  echo "It still in a process. Sleeping for 1 second..."
                  sleep 1
                  ((ATTEMPT++))
              done

              if [ -z "$ANSWER" ]; then
                echo "still in process, try to run 'curl localhost:30080/k8_calc' later"
              else
                echo -e "\nANSWER: $ANSWER"
              fi
            }

            echo -e "🧮 k8s_calc development environment loaded \n"
            echo "Quick start:"
            echo "  1. k8_calc_deploy"
            echo "  2. kubectl get pods  # ~30s before all load up"
            echo "  3. curl localhost:30080/k8_calc  # 69"
            echo "  4. k8_calc_recalc 2+2  # 4"
          '';
        };
      }
    );
}
