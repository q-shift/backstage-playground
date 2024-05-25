import {LitElement} from 'lit';

export class DemoChat extends LitElement {

   connectedCallback() {
    const chatBot = document.getElementsByTagName("chat-bot")[0];
    let socket;
    let secure = true;

    function connect() {
        socket = new WebSocket((secure ? "wss://" : "ws://") + window.location.host + "/chatbot");
        socket.onmessage = function (event) {
            chatBot.sendMessage(event.data, {
                right: false,
                sender: {name: 'Bob', id: '007'}
            });
        }

        chatBot.addEventListener("sent", function (e) {
            if (e.detail.message.right === true) {
                // User message
                socket.send(e.detail.message.message);
                chatBot.sendMessage("", {
                    right: false,
                    sender: {name: 'Bob', id: '007'},
                    loading: true
                });
            }
        });
    }
    // Try to connect
    connect();
    // If the connection is not open after a certain timeout, try to connect insecurely
    setTimeout(function() {
        if (socket.readyState !== WebSocket.OPEN) {
            secure = false;
            connect();
        }
    }, 5000); // 5 seconds timeout
  }
}

customElements.define('demo-chat', DemoChat);
