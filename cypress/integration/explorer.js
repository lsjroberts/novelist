describe('Explorer', () => {
    it('SHOULD add a scene', () => {
        cy.visit('/');

        cy.get('.explorer-explorer-file').should('have.length', 5);
        cy.get('.explorer-explorer-file:last').click();
        cy.get('.explorer-explorer-file').should('have.length', 6);
    });
});
