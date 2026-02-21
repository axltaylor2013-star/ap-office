// CLEAR INVOICES SCRIPT
// Run this in browser console on the invoices.html page to clear all fake data

console.log('🧹 Clearing invoice data...');

// Clear localStorage
localStorage.removeItem('kermicle-invoices');
console.log('✅ localStorage cleared');

// Clear the in-memory array if the page is loaded
if (typeof invoices !== 'undefined') {
  invoices = [];
  console.log('✅ In-memory invoices cleared');
  
  // Refresh the display if render function exists
  if (typeof render === 'function') {
    render();
    console.log('✅ Display refreshed');
  }
}

// Verification
const stored = localStorage.getItem('kermicle-invoices');
console.log('📊 Current localStorage data:', stored);
console.log('📊 Current invoices array:', typeof invoices !== 'undefined' ? invoices : 'Page not loaded');

console.log('🎉 Invoice cleanup complete! All fake data removed.');
console.log('💾 New invoices you create will now be properly saved and persist between sessions.');