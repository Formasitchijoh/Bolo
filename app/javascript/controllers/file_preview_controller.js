import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "preview"]

  show() {
    this.previewTarget.innerHTML = ""

    const files = Array.from(this.inputTarget.files)
    if (files.length === 0) return

    files.forEach(file => {
      if (!file.type.startsWith("image/")) return

      const reader = new FileReader()
      reader.onload = (e) => {
        const wrapper = document.createElement("div")
        wrapper.className = "preview-item"

        const img = document.createElement("img")
        img.src = e.target.result
        img.className = "preview-image"

        const name = document.createElement("span")
        name.className = "preview-name"
        name.textContent = file.name

        wrapper.appendChild(img)
        wrapper.appendChild(name)
        this.previewTarget.appendChild(wrapper)
      }
      reader.readAsDataURL(file)
    })
  }
}
