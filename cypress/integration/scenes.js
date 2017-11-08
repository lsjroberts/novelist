describe("Scenes", () => {
  it("SHOULD open a scene from the explorer", () => {
    cy.visit("/");
    cy.contains("Chapter Two").click();
  });
});
