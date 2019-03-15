# Pico Agents
Indy Agency based on the Pico-Engine

## Installing a pico engine

To support a Pico Agent, you will need the latest version of the pico engine,
running with the code of the `indy-krl` branch.

```
git clone https://github.com/Picolab/pico-engine.git
cd pico-engine/
git checkout -t origin/indy-krl
npm run setup
PORT=8080 npm start
```

This will start your pico engine at `http://localhost:8080`

## Registering pico rulesets with your pico engine

Using the ruleset editor built-in to your pico engine, register these rulesets:

```
https://raw.githubusercontent.com/Picolab/G2S/master/krl/html.krl
https://raw.githubusercontent.com/Picolab/G2S/master/krl/org.sovrin.agent.ui.krl
https://raw.githubusercontent.com/Picolab/G2S/master/krl/org.sovrin.agent_message.krl
https://raw.githubusercontent.com/Picolab/G2S/master/krl/org.sovrin.agent.krl
https://raw.githubusercontent.com/Picolab/G2S/master/krl/org.sovrin.wire_message.krl
```

The ruleset editor is at `http://localhost:8080/ruleset.html` and look for 
a box labelled "raw source URL" into which you will paste each of the above URLs,
then click the button labelled "register url" to perform the registration.

## Creating a Pico Agent

Once you have the five Sovrin agent rulesets registered, you create a pico, go to it,
and click on its Agent tab.
There you will see "To be an agent, install the org.sovrin.agent rulesets".
Click on the "install" link.
Your new pico is now a Pico Agent.
