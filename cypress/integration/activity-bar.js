const activeClass = 'activity-activity-item-active';

describe('Activity Bar', () => {
    beforeEach(() => {
        cy.visit('/');
    });

    it('SHOULD open on the manuscript', () => {
        cy.get('#activity-manuscript').should('have.class', activeClass);
    });

    it('SHOULD open each activity', () => {
        cy
            .get('#activity-characters')
            .click()
            .should('have.class', activeClass);

        cy
            .get('#activity-locations')
            .click()
            .should('have.class', activeClass);

        cy
            .get('#activity-search')
            .click()
            .should('have.class', activeClass);

        cy
            .get('#activity-plan')
            .click()
            .should('have.class', activeClass);

        cy
            .get('#activity-editor')
            .click()
            .should('have.class', activeClass);
    });
});
