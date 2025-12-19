# Vessel Icon Generation Prompt

Use this prompt with an AI image generator or designer to create the vessel type icons needed for the passage map application.

## Main Prompt

Create a set of 8 SVG icons for different vessel types, each 40x40 pixels with a viewBox of "0 0 40 40". All icons should follow a consistent design style matching the reference icon provided below.

**Reference Icon Style:**
- Outer circle with shadow effect (18px radius, blue color #007AFF with 0.9 opacity, white stroke 2px width)
- Inner circle (10px radius, white fill)
- Center element (5px radius, blue fill #007AFF)
- Clean, minimalist, maritime-themed design
- Suitable for use as map markers at small sizes

**Required Icons:**

1. **vessel-cargo.svg** - Cargo/Freight vessel
   - Design: Container ship silhouette or cargo boxes
   - Color scheme: Blue (#007AFF) with white accents
   - Should convey "commercial shipping" or "freight transport"

2. **vessel-tanker.svg** - Tanker vessel
   - Design: Oil tanker silhouette with distinctive tanker shape
   - Color scheme: Blue (#007AFF) with white accents
   - Should convey "liquid cargo transport"

3. **vessel-fishing.svg** - Fishing vessel
   - Design: Fishing boat silhouette, possibly with net or fishing elements
   - Color scheme: Blue (#007AFF) with white accents
   - Should convey "fishing" or "commercial fishing"

4. **vessel-passenger.svg** - Passenger/Ferry/Cruise vessel
   - Design: Passenger ship or ferry silhouette with multiple decks
   - Color scheme: Blue (#007AFF) with white accents
   - Should convey "passenger transport" or "people carrier"

5. **vessel-tug.svg** - Tug/Tow vessel
   - Design: Tugboat silhouette, compact and powerful-looking
   - Color scheme: Blue (#007AFF) with white accents
   - Should convey "tugboat" or "assistance vessel"

6. **vessel-sail.svg** - Sail/Yacht vessel
   - Design: Sailboat silhouette with mast and sail
   - Color scheme: Blue (#007AFF) with white accents
   - Should convey "sailing vessel" or "recreational sailing"

7. **vessel-military.svg** - Military/Navy vessel
   - Design: Naval ship silhouette, possibly with distinctive military features
   - Color scheme: Blue (#007AFF) with white accents
   - Should convey "military" or "naval vessel"

8. **vessel-marker.svg** - Default/Unknown vessel (already exists, use as reference)
   - Simple circular design with center dot
   - This is the fallback icon for unknown vessel types

**Technical Requirements:**
- Format: SVG
- Size: 40x40 pixels
- ViewBox: "0 0 40 40"
- Style: Minimalist, clean lines, recognizable at small sizes
- Colors: Primary blue (#007AFF), white (#FFFFFF), with optional shadow effects
- All icons should be visually distinct but maintain design consistency
- Icons should be centered in the 40x40 canvas
- Use simple shapes and silhouettes that are readable at map marker sizes (32-40px)

**Design Guidelines:**
- Keep designs simple and iconic - they need to be recognizable when small
- Use the same color palette across all icons for visual consistency
- Consider the maritime context - these represent vessels on water
- Each icon should be unique enough to distinguish vessel types at a glance
- Maintain the circular outer boundary style from the reference icon

**Output:**
Provide 8 separate SVG files, one for each vessel type listed above, ready to use as map markers in a web application.

