generate-icons:
	@mkdir -p src/icons;                                                                                                              \
	icons_json="{}";                                                                                                                  \
	for size in 256 512 1024; do                                                                                                      \
		magick convert -background none -resize $${size}x$${size} assets/icon.svg icons/icon_$${size}.png;                        \
		icons_json=$$(jq --arg size "$${size}" --arg file "icons/icon_$${size}.png" '. + {($$size): $$file}' <<< "$$icons_json");     \
	done;                                                                                                                             \
	jq --argjson icons "$$icons_json" '.icons = $$icons' manifest.json | sponge manifest.json;

clean-icons:
	rm -f src/icons/*

clean: clean-icons
