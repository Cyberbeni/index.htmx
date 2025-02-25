document.body.addEventListener('htmx:sseBeforeMessage', event => {
	if (event.detail.type == "reload") {
		event.preventDefault()
		location.reload()
	}
});
