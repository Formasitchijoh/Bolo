import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
	static targets = ["menu"]

	open(){
		this.element.classList.add("notification--open")
	}

	close(){
		this.element.classList.remove("notification--open")
		this.menuTarget.querySelector("turbo-frame").innerHTML = ""
	}
}