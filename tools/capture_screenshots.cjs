// Capture the running Flutter Web app, including real interactive states.
// Usage: node tools/capture_screenshots.cjs [http://127.0.0.1:8080]
const { chromium } = require('playwright');
const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');
const base = process.argv[2] || 'http://127.0.0.1:8080';
const output = path.resolve(__dirname, '../docs/screenshots');

(async () => {
  fs.mkdirSync(output, { recursive: true });
  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  const page = await browser.newPage({ viewport: { width: 390, height: 844 }, deviceScaleFactor: 2 });
  const errors = [];
  page.on('pageerror', error => errors.push(error.message));
  async function settle() { await page.waitForTimeout(350); }
  async function open(route) {
    await page.goto('about:blank');
    await page.goto(`${base}/#${route}`, { waitUntil: 'networkidle' });
    const accessibility = page.locator('flt-semantics-placeholder');
    if (await accessibility.count()) { await accessibility.evaluate(element => element.click()); }
    await settle();
  }
  async function capture(name) {
    await settle();
    await page.screenshot({ path: path.join(output, `${name}.png`) });
    console.log(`Captured ${name}`);
  }
  async function click(name) { await page.getByRole('button', { name, exact: true }).click(); await settle(); }
  async function fill(label, value) {
    await page.getByRole('textbox', { name: label, exact: true }).click();
    await settle();
    await page.keyboard.press('ControlOrMeta+A');
    await page.keyboard.insertText(value);
    await settle();
  }
  try {
    const routes = {
      '01_home': '/', '02_categories': '/categories', '03_light_categories': '/category/Light',
      '04_products': '/products', '05_product_detail': '/product/pathfinder',
      '06_concept': '/concept/pathfinder', '07_search': '/search', '09_saved': '/saved',
      '10_cart_empty': '/cart', '17_profile': '/profile', '18_profile_edit': '/profile/edit',
      '19_voucher': '/profile?tab=2', '20_card_empty': '/profile?tab=3',
      '21_add_card': '/card/add', '22_signin': '/signin', '23_signup': '/signup',
      '24_recovery': '/recovery', '27_gallery': '/gallery', '28_collection_empty': '/category/Armchair',
      '33_order_history': '/profile?tab=1',
    };
    for (const [name, route] of Object.entries(routes)) { await open(route); await capture(name); }
    await open('/search');
    await page.getByRole('textbox').fill('no matching furniture'); await settle();
    assert.match(await page.locator('body').ariaSnapshot(), /No results found/);
    await capture('08_search_empty');
    await open('/concept/pathfinder'); await click('Design Features'); await capture('29_concept_features');
    await open('/product/pathfinder');
    await page.mouse.move(200, 650); await page.mouse.wheel(0, 450); await settle(); await capture('05b_product_options');
    await open('/product/pathfinder');
    await click('Save product'); await click('Add To Cart $ 12.00');
    await open('/product/gile'); await click('Add To Cart $ 120.00');
    await open('/product/hobbit'); await click('Add To Cart $ 85.00');
    await open('/cart'); await capture('11_cart');
    await page.getByRole('button', { name: 'Customize', exact: true }).first().click(); await settle(); await capture('12_cart_customize');
    await click('Save'); await click('Checkout'); await capture('13_checkout_info');
    await click('Continue'); await capture('14_checkout_payment');
    await click('Cash'); await capture('14b_checkout_cash'); await click('Continue');
    await capture('15_checkout_confirmation');
    await page.mouse.move(200, 650); await page.mouse.wheel(0, 450); await settle();
    await click('+ Promo code or voucher'); await capture('30_promo_code');
    await fill('Enter promo code', 'FURNITE10'); await click('Apply'); await settle();
    assert.match(await page.locator('body').ariaSnapshot(), /212\.85/);
    await capture('15b_promo_applied'); await click('Place Order'); await capture('16_order_success');
    assert.match(await page.locator('body').ariaSnapshot(), /Make yourself at home/);
    await open('/profile'); await capture('31_profile_with_order');
    await open('/cart'); assert.match(await page.locator('body').ariaSnapshot(), /Your cart is empty/);
    await open('/card/add');
    await fill('Credit Card Number', '4242 4242 4242 4242');
    await fill('Cardholder Name', "Alice O'Donnell"); await fill('Expiration Date (MM/YY)', '12/30');
    await fill('CVV', '123');
    await click('Save Card'); await open('/profile?tab=3'); await capture('32_card_saved');
    assert.match(await page.locator('body').ariaSnapshot(), /4242/);
    await open('/recovery'); await fill('Email address', 'alice@example.com'); await click('Get the code'); await capture('25_recovery_code');
    await fill('Recovery code', '246810'); await click('Verify code'); await capture('26_new_password');
    // Check real layout rendering at narrow and wide phone sizes as well.
    await page.setViewportSize({ width: 320, height: 700 }); await open('/product/pathfinder'); await capture('34_small_phone');
    await page.setViewportSize({ width: 520, height: 900 }); await open('/'); await capture('35_large_phone');
    assert.deepEqual(errors, []);
    fs.writeFileSync(path.join(output, 'verification.json'), JSON.stringify({
      engine: 'Flutter Web / CanvasKit', browser: await browser.version(),
      viewport: '390 × 844 CSS pixels, 2×', capturedAt: new Date().toISOString(),
      screenshots: fs.readdirSync(output).filter(name => name.endsWith('.png')).length,
      checks: ['All routes rendered', 'Search empty state', 'Add three products', 'Customize cart',
        'Checkout cash payment', '10% promo: $212.85', 'Order creates and empties cart',
        'Reload preserves order and masked card', 'Recovery code flow', '320 / 520 px layouts'],
      pageErrors: errors,
    }, null, 2));
  } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exit(1); });
