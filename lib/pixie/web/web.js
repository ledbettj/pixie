'use strict';

const domContainer = document.querySelector('#container');
const e = React.createElement;
const { ChromePicker } = window.ReactColor;

class Effect extends React.Component {
  constructor(props) {
    super(props);
    this.id = props.id;
    this.name = props.effect.name;
    this.state = props.effect.config;
    this.onChange = props.onChange;
  }

  onChangeComplete = (color) => {
    this.setState({ color: color.hex }, () => {
      this.onChange(this.state);
    });
  }

  render() {
    return (
      <div>
        <h3>{this.name}</h3>
        <div>
          <ChromePicker
            disableAlpha={true}
            color={this.state.color}
            onChangeComplete={this.onChangeComplete}
          />
        </div>
      </div>
  );
  }
}

class PixieWeb extends React.Component {
  constructor(props) {
    super(props);
    this.state = { loaded: false, effects: [] };
  }

  componentDidMount() {
    fetch('./effects.json')
      .then(res => res.json())
      .then((result) => {
        this.setState({
          loaded: true,
          effects: result.effects
        });
      })
  }

  removeEffect = (index) => {
    this.setState({ loaded: false });
    fetch(`/effects/${index}.json`, {
      headers: { 'Accept': 'application/json' },
      method: 'DELETE'
    })
      .then(res => res.json())
      .then((result) => {
        this.setState({
          loaded: true,
          effects: result.effects
        });
      })
  }

  updateEffect = (index, effect, config) => {
    this.setState({ loaded: false });
    fetch(`/effects/${index}.json`, {
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(config),
      method: 'POST'
    })
      .then(res => res.json())
      .then((result) => {
        this.setState({ loaded: true })
      })
  }

  newWave = () => {
    
  }

  render() {
    return (
      <div>
        <h1>Pixie Web</h1>
        <div>
          <button disabled={!this.state.loaded} onClick={this.newWave}>new wave</button>
        </div>
        <ul>
          {this.state.effects.map((e, i) => (
            <li key={i}>
              <Effect effect={e} onChange={(conf) => (this.updateEffect(i, e, conf))} />
              <button disabled={!this.state.loaded} onClick={() => (this.removeEffect(i))}>remove</button>
            </li>
          ))}
        </ul>
      </div>
    )
  }
}

ReactDOM.render(e(PixieWeb), domContainer);
