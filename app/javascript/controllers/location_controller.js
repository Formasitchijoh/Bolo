import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["address", "latitude", "longitude", "status"]

  // Called when "Use my location" button is clicked
  useCurrentLocation() {
    if (!navigator.geolocation) {
      this.statusTarget.textContent = "Geolocation not supported"
      return
    }
    this.statusTarget.textContent = "Getting your location..."
    navigator.geolocation.getCurrentPosition(
      (position) => {
        this.latitudeTarget.value = position.coords.latitude
        this.longitudeTarget.value = position.coords.longitude
        this.statusTarget.textContent = "Location found"
      },
      () => {
        this.statusTarget.textContent = "Could not get location"
      }
    )
  }

  // Called when user finishes typing address
  searchAddress() {
    const address = this.addressTarget.value
    if (address.length < 3) return

    this.statusTarget.textContent = "Searching..."
    fetch(`https://nominatim.openstreetmap.org/search?format=json&q=${encodeURIComponent(address)}`)
      .then(response => response.json())
      .then(data => {
        if (data.length > 0) {
          this.latitudeTarget.value = data[0].lat
          this.longitudeTarget.value = data[0].lon
          this.statusTarget.textContent = "Address found"
        } else {
          this.statusTarget.textContent = "Address not found"
        }
      })
  }
}
