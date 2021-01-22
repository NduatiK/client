const config = require("../../config.js");
const { tr } = require("../../src/shared/translation.js");

Cypress.LocalStorage.clear = function (keys, ls, rs) {
  return;
}

describe('Document UI', () => {
  const testEmail = 'cypress@testing.com'

  before(() => {
    cy.deleteUser(testEmail)
    cy.signup(testEmail)
    cy.visit(config.TEST_SERVER + '/new')
  })

  beforeEach(() => {
    Cypress.Cookies.preserveOnce('AuthSession')
  })

  it('Opens Help menu dropdown on clicking icon', () => {
    let emailText = tr["emailSupport"]["en"];

    cy.url().should('match', /\/[a-zA-Z0-9]{5}$/)

    cy.get('#app-root')
      .should('not.contain', emailText)

    cy.get('#help-icon' )
      .click()

    cy.get('#help-dropdown')
      .contains(emailText)
  })

  it('Triggers mailto action on click', () => {
    cy.get('#email-support')
      .click()

    cy.window().then((win) => {
      expect(win.elmMessages.slice(-1)[0].tag).to.eq("TriggerMailto")
    })
  })

  it('Toggles the sidebar on clicking brand icon', () => {
    cy.get('#sidebar-menu').should('not.exist')
    cy.get('#brand').click()
    cy.get('#sidebar-menu').should('be.visible')
    cy.get('#brand').click()
    cy.get('#sidebar-menu').should('not.exist')
  })

  it('Toggles shortcut tray on clicking right-sidebar', () => {
    cy.contains('Keyboard Shortcuts')

    cy.get('#shortcuts-tray').click({position: "top"})

    cy.get('#app-root').should('not.contain', 'Keyboard Shortcuts')
  })

  it('Shows different shortcuts based on mode', () => {
    cy.get('#shortcuts-tray').click({position: "top"})
    cy.contains('(Edit Mode)')

    cy.writeInCard('This is a test')

    cy.shortcut('{ctrl}{enter}')

    cy.get('#app-root').should('not.contain', '(Edit Mode)')
  })

  it('Opens Markdown Format guide in external window', () => {
    cy.shortcut('{enter}')
    cy.get('#shortcuts a').should('have.attr', 'target', '_blank')
  })
})