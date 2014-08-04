# currently a replacement for alert(), cause alert() is hideous
Dialog = (title, internal) -> [
  m '.title', title
  m '.internal', internal
  m '.controls', [
    m 'input[type=button]',
      onclick: -> do document.querySelector('#dialog').close
      value: 'OK'
  ]
]