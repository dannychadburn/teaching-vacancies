module.exports = async (page, scenario, viewport, isReference, browserContext) => {
  console.log('SCENARIO ON BEFORE > ' + scenario.label);
  await require('./loadCookies')(browserContext, scenario, scenario.cookieConsent);
};
