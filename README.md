# Pico Agents
Indy Agency based on the Pico-Engine

## Installing a pico engine

To support a Pico Agent, you will need the latest version of the pico engine.

```
git clone https://github.com/Picolab/pico-engine.git
cd pico-engine/
npm run setup
PICO_ENGINE_HOST=http://localhost:8080 PORT=8080 npm start
```

This will start your pico engine at `http://localhost:8080`

## Registering agent rulesets with your pico engine

Using the ruleset editor built-in to your pico engine, register these rulesets:

```
https://raw.githubusercontent.com/Picolab/G2S/master/krl/html.krl
https://raw.githubusercontent.com/Picolab/G2S/master/krl/webfinger.krl
https://raw.githubusercontent.com/Picolab/G2S/master/krl/org.sovrin.agent.ui.krl
https://raw.githubusercontent.com/Picolab/G2S/master/krl/org.sovrin.agent_message.krl
https://raw.githubusercontent.com/Picolab/G2S/master/krl/org.sovrin.agent.krl
```

The ruleset editor is at `http://localhost:8080/ruleset.html` and look for 
a box labelled "raw source URL" into which you will paste each of the above URLs,
then click the button labelled "register url" to perform the registration.

You might wish to use [this page](https://picolab.github.io/G2S/rids.html)
and click on
the links in order from top to bottom to register these rulesets.

## Creating a Pico Agent

Once you have the five Sovrin agent rulesets registered, you create a pico, go to it,
and click on its Agent tab.
There you will see "To be an agent, install the org.sovrin.agent rulesets".
Click on the "install" link.
Your new pico is now a Pico Agent.

## Pico Agent with ngrok
After installing ngrok, start ngrok with http requests being directed to port 8080.
```
./ngrok http 8080 
```
In a different terminal start the pico-engine with the host pointed to the domain provided from starting ngrok. 
For example.
```
PICO_ENGINE_HOST=https://e28640da.ngrok.io npm start
```

## Running a Pico Agency

Start with a fresh pico engine (as above).

You will need to register these additional rulesets for agencies:

```
https://raw.githubusercontent.com/Picolab/G2S/master/krl/colors.krl
https://raw.githubusercontent.com/Picolab/G2S/master/krl/org.sovrin.agency.ui.krl
https://raw.githubusercontent.com/Picolab/G2S/master/krl/org.sovrin.agency.krl
https://raw.githubusercontent.com/Picolab/G2S/master/krl/org.sovrin.agency_agent.krl
https://raw.githubusercontent.com/Picolab/G2S/master/krl/org.sovrin.agents.krl
```

In the Root Pico install the `io.picolabs.account_management` ruleset.

Click on the link "Need an owner pico?" to create a pico named "Agency"
with a password you will need to remember briefly. Click "Submit".

Login with the owner id "Agency" and the password.

Visit the About tab of your Agency pico. You may change its name and color
(for Sovrin, use #f6a12b).

Install the `org.sovrin.agency` ruleset. This makes your pico be
an Agency Pico.

In the Channels tab, create a new channel, say ui/application and
remember the ECI.

In a browser, visit a URL like this one, using the ECI from your Agency pico.

```
localhost:8080/sky/cloud/<ECI>/org.sovrin.agency/html.html
```

Use the UI it presents to create new Agent Picos. Follow the HATEOS link to login as the owner of a new Agent Pico.

Each one will be named with an email addresses, and also can be given
a color, and a label for its invitations/connections.

### Retiring a Pico Agency

1. In the Agents pico, visit the Testing tab, open the `io.picolabs.collection` box, and click on "wrangler/deletion_imminent"
2. Visit the About tab, click on the Parent ID, then the "del" link beside the name of the agency pico
3. In the Root pico, visit the About tab and delete all its child picos
4. Visit the Rulesets tab and delete the rulesets `io.picolabs.account_management` and `io.picolabs.owner_authentication`
5. Click the "logout" button in the upper-right corner of the UI

## Agent intermediaries

Agents have a built-in ability to forward messages along an in-bound route.

So that an agent can be used as an intermediary, you will need to register
this additional ruleset, and install it in that Agent Pico.

```
https://raw.githubusercontent.com/Picolab/G2S/master/krl/org.sovrin.router.krl
```
You will need to register
this additional ruleset for edge agents.

```
https://raw.githubusercontent.com/Picolab/G2S/master/krl/org.sovrin.edge.krl
```

When you install this ruleset in a Pico Agent, it will be able to set up
an inbound route involving one intermediary.
