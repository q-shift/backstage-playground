import {LitElement, html, css} from 'lit';

export class DemoTitle extends LitElement {

    static styles = css`
      h1 {
        font-family: "Red Hat Mono", monospace;
        font-size: 60px;
        font-style: normal;
        font-variant: normal;
        font-weight: 700;
        line-height: 26.4px;
        color: var(--main-highlight-text-color);
      }

      .title {
        text-align: center;
        padding: 1em;
        background: var(--main-bg-color);
      }
      
      .explanation {
        margin-left: auto;
        margin-right: auto;
        width: 50%;
        text-align: justify;
        font-size: 20px;
      }
      
      .explanation img {
        max-width: 60%;
        display: block;
        float:left;
        margin-right: 2em;
        margin-top: 1em;
      }
    `

    render() {
        return html`
            <div class="title">
                <h1>Api Chatbot</h1>
            </div>

            <div class="explanation">
            </div>

            <div class="explanation">
                <img src="images/chatbot-architecture.png"/>
            </div>

            
            <div class="explanation">
                <ol>
                    <li>API is registered in the Catalog</li>
                    <li>Chatbot lookus up the API from the Catalog</li>
                    <li>Each method of the API is registered as tool to the LLM</li>
                    <li>The user sends a question.</li>
                    <li>The chatbot will call the LLM.</li>
                    <li>The LLM's may request the use of a tool.</li>
                    <li>The chatbot will invoke the tool and return the result to the LLM.</li>
                    <li>The LLM will return the result to the chatbot.</li>
                    <li>The chatbot will return the result to the user.</li>
                </ol>
            </div>
        `
    }
}

customElements.define('demo-title', DemoTitle);
