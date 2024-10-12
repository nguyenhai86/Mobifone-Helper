// Lấy tất cả các phần tử có lớp là 'lSSlideOuter'
var elements = document.querySelectorAll('.lSSlideOuter');

// Duyệt qua từng phần tử và loại bỏ lớp 'lSSlideOuter'
elements.forEach(function (element) {
  element.classList.remove('lSSlideOuter');
});
// Lấy tất cả các phần tử có lớp là 'lSSlideWrapper '
elements = document.querySelectorAll('.lSSlideWrapper');

// Duyệt qua từng phần tử và loại bỏ lớp 'lSSlideWrapper  '
elements.forEach(function (element) {
  element.classList.remove('lSSlideWrapper');
});

elements = document.querySelectorAll('.lsGrab');

// Duyệt qua từng phần tử và loại bỏ lớp 'lSSlideWrapper  '
elements.forEach(function (element) {
  element.classList.remove('lsGrab');
});

elements = document.querySelectorAll('.lSSlide');

// Duyệt qua từng phần tử và loại bỏ lớp 'lSSlideWrapper  '
elements.forEach(function (element) {
  element.classList.remove('lSSlide');
});

// Lấy tất cả các phần tử có lớp là 'lightSlider  '
var elements = document.querySelectorAll('.lightSlider');

// Duyệt qua từng phần tử và loại bỏ lớp 'lightSlider '
elements.forEach(function (element) {
  element.classList.remove('lightSlider');
});
var elements = document.querySelectorAll('.mb');
console.log(elements);

// Lấy tất cả các phần tử có lớp là 'lslide  '
var elements = document.querySelectorAll('.lslide');

// Duyệt qua từng phần tử và loại bỏ lớp 'lslide '
elements.forEach(function (element) {
  element.classList.remove('lslide');
});

// Get all the mobile charge cards
const mobileChargeCards = document.querySelectorAll('.m-card.mobile-charge');

// Convert the NodeList to an array for easier manipulation
const mobileChargeArray = Array.from(mobileChargeCards);

// Sort the array based on the price
mobileChargeArray.sort((a, b) => {
  // Extract price values from the elements
  const priceA = parseFloat(a.querySelector('.price-mobi-service').textContent.replace(/\D/g, ''));
  const priceB = parseFloat(b.querySelector('.price-mobi-service').textContent.replace(/\D/g, ''));

  // Compare prices
  return priceA - priceB;
});

// Clear existing cards
const mobileChargeContainer = document.querySelector('.mb.cs-hidden');
mobileChargeContainer.innerHTML = '';
mobileChargeContainer.style.width = '100%';
mobileChargeContainer.style.height = '';

// Append sorted cards back to the container
mobileChargeArray.forEach((card) => {
  mobileChargeContainer.appendChild(card);
});

// highlight
const contents = ['GO', 'RAS', 'RSD', 'EU2', 'Roam Share', 'border'].map((content) =>
  content.toLowerCase()
);

document.querySelectorAll('h3.title a').forEach(function (a) {
  let text = a.textContent.trim().toLowerCase();
  contents.forEach(function (content) {
    if (text.includes(content)) {
      a.classList.add('highlight-text__primary');
    }
  });
});

const unlimited = ['không giới hạn'].map((content) => content.toLowerCase());

document.querySelectorAll('h3.title a').forEach(function (a) {
  let text = a.textContent.trim().toLowerCase();
  unlimited.forEach(function (content) {
    if (text.includes(content)) {
      a.classList.add('highlight-text__secondary');
    }
  });
});
