/*global axios:false*/

import React, { Component } from 'react';
// import logo from './logo.svg';
import './App.css';

class App extends Component {

  constructor(props) {
    super(props);
    
    this.state = {
      sessions: [], // TODO: Templorary, this should not be here
      test: ""
    };
  }
  
  componentDidMount(){
    axios
      .get('http://localhost:3000/getallsessions')
      .then(({ data })=> {
      	this.setState({ 
          sessions: data, 
        });
      })
      .catch((err)=> {})
  }

  onGenTestCase(uid) {
    axios
      .get('http://localhost:3000/gettest/' + uid)
      .then(({ data })=> {
        console.log(data.test);

        // alert(data.test);
        this.setState({
          test: data.test
        });
      })
      .catch((err)=> {})

    // alert("uid is : " + uid);
  }

  render() {
    const child = this.state.sessions.map((el, index) => {
      return <li key={index}>
        <p>UID - { el.event_uid }</p>
        <button onClick={this.onGenTestCase.bind(this, el.event_uid)}>Generate Test Case for Yo Mama</button>
      </li>
    });

    return (
      <div className="App">
        <header className="App-header">
          <img src="http://www.muttville.org/images/mutts/105/8/0/105807-100002-lgsq.jpg?1504770576" className="App-logo" alt="logo" />
          <h1 className="App-title">Welcome to No-More-QA Dashboard (FrontEnd component)</h1>
        </header>
        <p className="App-intro">
          {/* To get started, edit <code>src/App.js</code> and save to reload. */}
        </p>

        <ul>
          {child}
        </ul>

        <code style={{ display: 'block', 'white-space': 'pre-wrap', textAlign: 'left'}}>
          {this.state.test}
        </code>
      </div>
    );
  }
}

export default App;
