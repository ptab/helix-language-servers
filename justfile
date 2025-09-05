default: build run

build:
    devcontainer build --workspace-folder .

run:
    devcontainer up --workspace-folder . --id-label name=language-servers --remove-existing-container
