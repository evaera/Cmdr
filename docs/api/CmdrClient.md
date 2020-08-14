---
title: CmdrClient
docs:
  extends: Cmdr
  tags:
    - client only
  functions:
    - name: SetActivationKeys
      desc: Sets the key codes that will hide or show Cmdr.
      params:
        - name: keys
          type: array<Enum.KeyCode>
    - name: SetPlaceName
      desc: Sets the place name label that appears when executing commands. This is useful for a quick way to tell what game you're playing in a universe game.
      params:
        - name: labelText
          type: string
    - name: SetEnabled
      desc: Sets whether or not Cmdr can be shown via the defined activation keys. Useful for when you want users to need to opt-in to show the console in a settings menu.
      params:
        - name: isEnabled
          type: boolean
    - name: Show
      desc: Shows the Cmdr window explicitly. Does not do anything if Cmdr is not enabled.
    - name: Hide
      desc: Hides the Cmdr window.
    - name: Toggle
      desc: Toggles visibility of the Cmdr window. Will not show if Cmdr is not enabled.
    - name: HandleEvent
      params:
        - name: event
          type: string
        - name: handler
          type:
            kind: function
            params:
              - name: "..."
                type: any?
    - name: SetMashToEnable
      params:
        - name: isEnabled
          type: boolean
    - name: SetActivationUnlocksMouse
      params:
        - name: isEnabled
          type: boolean
    - name: SetHideOnLostFocus
      since: v1.6.0
      params:
        - name: isEnabled
          type: boolean
  properties:
    - name: Enabled
      type: boolean
    - name: PlaceName
      type: string
    - name: ActivationKeys
      type: dictionary<Enum.KeyCode, true>

---

<ApiDocs />
