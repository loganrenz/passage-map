# Passage Map

A Nuxt 4 application that visualizes vessel passages on an Apple MapKitJS map, built with Nuxt UI 4.

## Features

- Interactive MapKitJS map visualization
- Display vessel passages with routes and markers
- Passage list with search functionality
- Detailed passage information panel
- Support for multiple passages
- Responsive design with Nuxt UI 4
- Built with Nuxt 4 and TypeScript

## Setup

1. Install dependencies:
```bash
npm install
```

2. Set up Doppler for local development (see [Doppler Setup Guide](./docs/DOPPLER_SETUP.md)):
```bash
# Install Doppler CLI
brew install dopplerhq/cli/doppler

# Authenticate
doppler login

# Set up project
doppler setup
```

3. Copy passage data to `public/data/passages/`

4. Start development server with Doppler:
```bash
doppler run -- npm run dev
```

The dev server will run on `phantom.curl-banjo.ts.net` by default.

## Project Structure

- `components/` - Vue components (PassageMap, PassageList, PassageInfo)
- `composables/` - Vue composables (useMapKit, usePassageData)
- `types/` - TypeScript type definitions
- `utils/` - Utility functions (passageLoader, mapHelpers)
- `pages/` - Nuxt pages
- `public/data/passages/` - Passage JSON data files

## MapKitJS Setup

The application uses MapKit JS tokens from Doppler for local development. See the [Doppler Setup Guide](./docs/DOPPLER_SETUP.md) for details on configuring the `MAPKIT_DEV_TOKEN` secret.

## Data Format

Passage JSON files should follow this structure:

```json
{
  "id": "passage_1234567890",
  "startTime": "2025-01-01T00:00:00Z",
  "endTime": "2025-01-02T12:00:00Z",
  "duration": 36,
  "avgSpeed": 5.5,
  "maxSpeed": 8.2,
  "distance": 198.0,
  "startLocation": { "lat": 25.1234, "lon": -80.5678 },
  "endLocation": { "lat": 29.8765, "lon": -95.4321 },
  "description": "Passage description",
  "name": "Passage Name",
  "route": "25.12, -80.57 → 29.88, -95.43"
}
```

## Development

```bash
# Development server (with Doppler)
doppler run -- npm run dev

# Build for production
npm run build

# Preview production build
npm run preview
```

