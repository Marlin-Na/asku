
(function() {

    function onload() {
        let divs = document.getElementsByClassName("asku_hidden_wrapper");
        for (let div of divs) {
            try {
                init_asku(div);
            }
            catch (err) {
                console.error(err);
            }
        }
    }

    function init_asku(div) {
        let hidden_data = div.getAttribute("hidden_data");
        let content = atob(hidden_data);
        let A       = atob(div.getAttribute("hidden_ans"));
        let form    = div.children[0];

        form.addEventListener("submit", handler, false);

        function handler(event) {
            event.preventDefault();
            let data = new FormData(form);
            let ans = data.get("askuA");
            if (ans !== A) {
                // The answer is incorrect, do nothing?
                return;
            }
            // Bingo
            div.innerHTML = content;
        }
    }

    document.addEventListener("DOMContentLoaded", onload, false);

})();
