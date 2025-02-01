# Variables
VERSION := $(shell jq --raw-output ".version" src/manifest.json)
NAME := $(shell jq --raw-output ".name" src/manifest.json | sed -e 's/\(.*\)/\L\1/' -e 's/ /-/g')
DOCKER_IMAGE = $(NAME)/extension-builder:$(VERSION)

# Targets
clean-icons:
	rm -f src/icons/*
	jq 'del(.icons)' src/manifest.json | sponge src/manifest.json

clean-docker:
	docker image rm $(DOCKER_IMAGE) || true

clean-dist:
	rm -rf dist/*

clean-bundle:
	rm -f src/bundle.js

clean: clean-icons clean-docker clean-dist clean-bundle

setup-git-filters:
	git config --global filter.ignore-manifest-icons.clean "jq 'del(.icons)'"
	git config --global filter.ignore-manifest-icons.smudge cat

generate-icons: setup-git-filters
	@mkdir -p src/icons;                                                                                                          \
	icons_json="{}";                                                                                                              \
	for size in 48 256 512; do                                                                                                    \
		magick convert -background none -resize $${size}x$${size} assets/icon.svg src/icons/icon_$${size}.png;                    \
		icons_json=$$(jq --arg size "$${size}" --arg file "icons/icon_$${size}.png" '. + {($$size): $$file}' <<< "$$icons_json"); \
	done;                                                                                                                         \
	jq --argjson icons "$$icons_json" '.icons = $$icons' src/manifest.json | sponge src/manifest.json;

npm-install:
	npm install

bundle-js: npm-install
	node_modules/esbuild/bin/esbuild src/content.js --bundle --outfile=src/bundle.js

debug: generate-icons bundle-js

docker-builder:
	if [ -z "$(shell docker images -q $(DOCKER_IMAGE))" ]; then              \
		docker build -t $(DOCKER_IMAGE) .;                                   \
	else                                                                     \
		echo "Docker image $(DOCKER_IMAGE) already exists, skipping build."; \
	fi

build: clean-dist generate-icons docker-builder
	docker run --rm               \
	-v $(PWD)/secrets:/secrets    \
	-v $(PWD)/dist:/dist          \
	-v $(PWD)/src:/extension-pack \
	$(DOCKER_IMAGE) $(ARGS)
