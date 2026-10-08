# Selected CC0 source assets

Only the fifteen models used by the Golden refresh and the selected Kenney UI
sources are checked in. The complete downloaded library remains outside this
repository at `C:\Users\Loren\MonsterVault-AssetLibrary`.

- Quaternius Stylized Nature MegaKit, Standard: eight selected environment models.
- Quaternius Modular SciFi MegaKit, Standard: seven selected architecture/prop models.
- Kenney Input Prompts and UI Pack: Sci-fi: six selected PNGs and available vector sources.

The original license texts accompany each pack. All four supplied licenses state
CC0. Credit: Quaternius (`quaternius.com`) and Kenney (`kenney.nl`).

The selected glTF files retain their geometry, UVs and required buffer/image
resources. Their image URIs are repaired to adjacent files because some supplied
Standard glTFs referenced textures stored elsewhere in the downloaded ZIP.
`refresh_manifest.json` records hashes of these staged dependencies.

`tools/blender/adapt_refresh_library.py` defaults to this directory, so regeneration
does not require another download. It makes palette-colored atlases at <=512px,
normalizes scale/orientation and preserves editable packed `.blend` sources.
Original high-resolution source maps are authoring inputs, not runtime textures.

`tools/blender/validate_refresh_sources.py` audits the saved Blender/GLB geometry,
UVs, transforms, texture packing, bounds and source hashes without modifying them.
The native Studio prefab IDs and atlas mapping are in
`assets/exported/refresh/native_asset_manifest.json`.
