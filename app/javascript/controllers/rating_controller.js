import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "star"]

  highlight(event) {
    const n = parseInt(event.currentTarget.dataset.value)
    this.starTargets.forEach(star => {
      star.classList.toggle("rating-star--active", parseInt(star.dataset.value) <= n)
    })
  }

  reset() {
    const selected = parseInt(this.inputTarget.value) || 0
    this.starTargets.forEach(star => {
      star.classList.toggle("rating-star--active", parseInt(star.dataset.value) <= selected)
    })
  }

  submit(event) {
    this.locked = true
    const n = event.currentTarget.dataset.value
    this.inputTarget.value = n
    this.starTargets.forEach(star => {
      star.classList.toggle("rating-star--active", parseInt(star.dataset.value) <= parseInt(n))
    })
    this.element.requestSubmit()
  }
}
