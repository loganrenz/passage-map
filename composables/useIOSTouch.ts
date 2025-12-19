/**
 * Composable for handling iOS touch events properly
 * Eliminates the 300ms click delay on iOS by using touchstart events
 */
export function useIOSTouch() {
  /**
   * Handle touch/click events with immediate response on iOS
   * Returns a handler that works for both touch and click events
   */
  const handleTouch = (callback: (e: MouseEvent | TouchEvent) => void) => {
    return (e: MouseEvent | TouchEvent) => {
      // For touch events, prevent default to avoid double-firing
      if ('touches' in e) {
        e.preventDefault()
        callback(e)
      } else {
        // For mouse events, just call the callback
        callback(e)
      }
    }
  }

  /**
   * Handle touchstart with immediate execution (no delay)
   * Use this for buttons and interactive elements
   */
  const onTouchStart = (callback: (e: TouchEvent) => void) => {
    return (e: TouchEvent) => {
      e.preventDefault()
      callback(e)
    }
  }

  /**
   * Check if device is iOS
   */
  const isIOS = () => {
    if (typeof window === 'undefined') return false
    return /iPad|iPhone|iPod/.test(navigator.userAgent) ||
      (navigator.platform === 'MacIntel' && navigator.maxTouchPoints > 1)
  }

  return {
    handleTouch,
    onTouchStart,
    isIOS,
  }
}

