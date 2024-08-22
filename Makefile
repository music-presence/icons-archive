INKSCAPE_FILE=icons.inkscape.svg
EXPORT_DIR=build
OUT_DIR=dist
OUT_DIR_ICO=$(OUT_DIR)/ico
OUT_DIR_ICNS=$(OUT_DIR)/icns
OUT_DIR_PATREON=$(OUT_DIR)/patreon
OUT_DIR_INSTALLER=$(OUT_DIR)/installer
OUT_DIR_SYMBOLS=$(OUT_DIR)/symbols
DEPS_DIRS=$(OUT_DIR) $(OUT_DIR_ICO) $(OUT_DIR_ICNS) $(OUT_DIR_PATREON) $(OUT_DIR_INSTALLER) $(OUT_DIR_SYMBOLS)
DEPS=node_modules $(DEPS_DIRS)
OUT_SIZE=512
OUT_SIZE_SMALL=448
OUT_SIZE_DOUBLE=1024

BACKGROUNDS=blurple-circle blurple-squircle blurple-squircle-mac blurple-square
ICON_OUT=$(addsuffix .png,$(addprefix $(OUT_DIR)/icon_,$(BACKGROUNDS)))
ICON_SMALL_OUT=$(OUT_DIR)/icon-small.png $(OUT_DIR)/icon-small-enabled.png $(OUT_DIR)/icon-small-disabled.png
ICON_PATREON_OUT=$(OUT_DIR_PATREON)/icon-patreon-early.png $(OUT_DIR_PATREON)/icon-patreon-gold.png $(OUT_DIR_PATREON)/icon-patreon-platinum.png
INSTALLER_WIZARD_OUT=$(OUT_DIR_INSTALLER)/installer-wizard.bmp
INSTALLER_HEADER_OUT=$(OUT_DIR_INSTALLER)/installer-header.bmp
INSTALLER_DMG_OUT=$(OUT_DIR_INSTALLER)/installer-dmg.png
INSTALLER_IMAGES_OUT=$(INSTALLER_WIZARD_OUT) $(INSTALLER_HEADER_OUT) $(INSTALLER_DMG_OUT)
ICONS=$(ICON_OUT) $(ICON_SMALL_OUT) $(OUT_DIR)/icon-small-light.png
ICONS_CONVERTED=$(patsubst $(OUT_DIR)/%.png,$(OUT_DIR_ICO)/%.ico,$(ICONS)) $(patsubst $(OUT_DIR)/%.png,$(OUT_DIR_ICNS)/%.icns,$(ICONS))
ICONS_ALL=$(ICONS) $(ICONS_CONVERTED) $(OUT_DIR)/favicon.ico $(ICON_PATREON_OUT)

# Note that with the inkscape export command and --export-id-only (-j)
# all elements with the specified IDs are exported, but the bounding box
# of the export is determined by the last element mentioned.
# By putting "black-circle" at the end the logo is trimmed to the background
# and we don't need to trim it with another tool.

all: clean $(DEPS) $(ICONS_ALL) symbols $(INSTALLER_IMAGES_OUT)

symbols: node_modules
	inkscape -o $(OUT_DIR_SYMBOLS)/symbol-x-light.png -i symbol-x-light -j -h $(OUT_SIZE) symbols.inkscape.svg
	magick $(OUT_DIR_SYMBOLS)/symbol-x-light.png -channel RGB -negate $(OUT_DIR_SYMBOLS)/symbol-x-dark.png
	npx icon-gen -i $(OUT_DIR_SYMBOLS)/symbol-x-light.png -o $(OUT_DIR_SYMBOLS) --ico --ico-name symbol-x-light
	npx icon-gen -i $(OUT_DIR_SYMBOLS)/symbol-x-dark.png -o $(OUT_DIR_SYMBOLS) --ico --ico-name symbol-x-dark
	inkscape -o $(OUT_DIR_SYMBOLS)/symbol-info-light.png -i symbol-info-light -j -h $(OUT_SIZE) symbols.inkscape.svg
	magick $(OUT_DIR_SYMBOLS)/symbol-info-light.png -channel RGB -negate $(OUT_DIR_SYMBOLS)/symbol-info-dark.png
	npx icon-gen -i $(OUT_DIR_SYMBOLS)/symbol-info-light.png -o $(OUT_DIR_SYMBOLS) --ico --ico-name symbol-info-light
	npx icon-gen -i $(OUT_DIR_SYMBOLS)/symbol-info-dark.png -o $(OUT_DIR_SYMBOLS) --ico --ico-name symbol-info-dark
	inkscape -o $(OUT_DIR_SYMBOLS)/symbol-open-light.png -i symbol-open-light -j -h $(OUT_SIZE) symbols.inkscape.svg
	magick $(OUT_DIR_SYMBOLS)/symbol-open-light.png -channel RGB -negate $(OUT_DIR_SYMBOLS)/symbol-open-dark.png
	npx icon-gen -i $(OUT_DIR_SYMBOLS)/symbol-open-light.png -o $(OUT_DIR_SYMBOLS) --ico --ico-name symbol-open-light
	npx icon-gen -i $(OUT_DIR_SYMBOLS)/symbol-open-dark.png -o $(OUT_DIR_SYMBOLS) --ico --ico-name symbol-open-dark
	inkscape -o $(OUT_DIR_SYMBOLS)/symbol-heart.png -i symbol-heart -j -h $(OUT_SIZE) symbols.inkscape.svg
	npx icon-gen -i $(OUT_DIR_SYMBOLS)/symbol-heart.png -o $(OUT_DIR_SYMBOLS) --ico --ico-name symbol-heart

$(ICON_SMALL_OUT) $(ICON_PATREON_OUT):
	inkscape -o $@ -i $(basename $(notdir $@)) -j -h $(OUT_SIZE_DOUBLE) $(INKSCAPE_FILE)
	magick $@ -trim -resize x$(OUT_SIZE_SMALL) -background none -gravity center -extent $(OUT_SIZE)x$(OUT_SIZE) $@

$(OUT_DIR)/icon-small-light.png:
	inkscape -o $@ -i icon-small-background-transparent\;icon-small-parts -j -h $(OUT_SIZE_DOUBLE) $(INKSCAPE_FILE)
	magick $@ -trim -resize x$(OUT_SIZE_SMALL) -background none -gravity center -extent $(OUT_SIZE)x$(OUT_SIZE) $@

$(ICON_OUT):
	inkscape -o $@ -i $(subst _,\;,$(basename $(notdir $@))) -j -h $(OUT_SIZE) $(INKSCAPE_FILE)

# Recommended size: https://nsis.sourceforge.io/Docs/Modern%20UI/Readme.html#toggle_inwf
$(INSTALLER_WIZARD_OUT):
	inkscape -o $(patsubst %.bmp,%.png,$@) \
		-i $(basename $(notdir $@))\;$(basename $(notdir $@))-rect \
		-j -h 314 -w 164 $(INKSCAPE_FILE)
	magick $(patsubst %.bmp,%.png,$@) BMP3:$@

# Recommended size: https://nsis.sourceforge.io/Docs/Modern%20UI/Readme.html#toggle_ingen
$(INSTALLER_HEADER_OUT):
	inkscape -o $(patsubst %.bmp,%.png,$@) \
		-i $(basename $(notdir $@))\;$(basename $(notdir $@))-rect \
		-j -h 57 -w 150 $(INKSCAPE_FILE)
	magick $(patsubst %.bmp,%.png,$@) BMP3:$@

# 1200x730, 144 = 72 * 2 DPI (required on Mac?)
$(INSTALLER_DMG_OUT):
	inkscape -o $@ \
		-i $(basename $(notdir $@))\;$(basename $(notdir $@))-rect \
		-j -h 730 -w 1200 $(INKSCAPE_FILE)
	magick $@ -units "PixelsPerInch" -density 144 $@

$(OUT_DIR)/favicon.ico: $(OUT_DIR)/icon-small.png
	mkdir -p .tmp; \
		npx icon-gen -i $< -o .tmp --favicon --favicon-name $(basename $(notdir $@)); \
		cp .tmp/$(notdir $@) $(dir $@); \
		rm -rf .tmp

$(OUT_DIR)/ico/%.ico: $(OUT_DIR)/%.png
	npx icon-gen -i $< -o $(dir $@) --ico --ico-name $(basename $(notdir $@))

$(OUT_DIR)/icns/%.icns: $(OUT_DIR)/%.png
	npx icon-gen -i $< -o $(dir $@) --icns --icns-name $(basename $(notdir $@))

$(DEPS_DIRS):
	mkdir -p $@

node_modules:
	npm install

clean:
	rm -rf $(OUT_DIR)

.PHONY: all update-resources symbols clean
