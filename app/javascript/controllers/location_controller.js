import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["address", "latitude", "longitude", "status"]

  /*
  References:
  - Geolocation API: https://developer.mozilla.org/en-US/docs/Web/API/Geolocation_API
  - Nominatim API: https://nominatim.org/release-docs/latest/
  */
  useCurrentLocation() {
    if (!navigator.geolocation) {
      this.statusTarget.textContent = "Geolocation not supported"
      return
    }
    this.statusTarget.textContent = "Getting your location..."
    navigator.geolocation.getCurrentPosition(
      (position) => {
        const lat = position.coords.latitude
        const lon = position.coords.longitude

        this.latitudeTarget.value = lat
        this.longitudeTarget.value = lon

        fetch(`https://nominatim.openstreetmap.org/reverse?format=json&lat=${lat}&lon=${lon}`)
          .then(response => response.json())
          .then(data => {
            if (data && data.display_name) {
              this.addressTarget.value = data.display_name
              this.statusTarget.textContent = "✓ Location found"
            }
          })
          .catch(() => {
            this.statusTarget.textContent = "✓ Location found"
          })
      },
      () => {
        this.statusTarget.textContent = "Could not get location"
      }
    )
  }

  searchAddress() {
    const address = this.addressTarget.value
    if (address.length < 3) {
      this.statusTarget.textContent = ""
      return
    }

    // Wait 500ms after user stops typing before hitting the API
    clearTimeout(this.debounceTimer)
    this.debounceTimer = setTimeout(() => {
      this.statusTarget.textContent = "Searching..."
      fetch(`https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(address)}`)
        .then(response => response.json())
        .then(data => {
          if (data.length > 0) {
            this.latitudeTarget.value = data[0].lat
            this.longitudeTarget.value = data[0].lon
            this.statusTarget.textContent = "✓ Address found"
          } else {
            this.statusTarget.textContent = "Address not found — try a different search"
          }
        })
    }, 500)
  }
}
