/*global axios:false*/

import React, { Component } from 'react';
import logo from './logo.svg';
import './App.css';

class App extends Component {

  constructor(props) {
    super(props);
    
    this.state = {
      sessions: []
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

  render() {
    const child = this.state.sessions.map((el, index) => {
      return <div key={index}>
        <p>UID - { el.event_uid }</p>
      </div>
    });

    return (
      <div className="App">
        <header className="App-header">
          <img src={logo} className="App-logo" alt="logo" />
          <h1 className="App-title">Welcome to React</h1>
        </header>
        <p className="App-intro">
          To get started, edit <code>src/App.js</code> and save to reload.
        </p>

        <div>
          {child}
        </div>
      </div>
    );
  }
}

export default App;
