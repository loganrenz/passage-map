/// <reference types="@types/apple-mapkit-js-browser" />

declare global {
  interface Window {
    mapkit: typeof mapkit
  }
}

export {}

