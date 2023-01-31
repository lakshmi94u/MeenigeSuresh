var assert = require('assert');
var getIn = require('../index.js');

console.log(getIn);

var object = {
    firstName: "suresh",
    lastName: "m",
    address: {
        home: {
            addressLines: {
                1: "Flat 100",
                2: "bakery road"
            }
        }
    },
    customerType : {
        retail: {
            channel: "Top100",
            spending: "Top10",
        }
    }
};
describe('Index', function() {
  describe('#getIn', function() {
    it('Should throw error for invalid JSON', function() {
      assert.throws(function () { getIn("", ["key"]) }, Error, "Invalid JSON");
    });
    it('Should throw error for invalid Keys', function() {
      assert.throws(function () { getIn(object, []) }, Error, "Invalid Keys");
    });
    it('Should give the firstname ', function () {
          assert.equal(getIn(object,['firstName']), object.firstName);
    });  
    it('Should give the  object.address.home.addressLines', function () {
          assert.equal(getIn(object,[ "address", "home", "addressLines"]), object.address.home.addressLines);
    });
    it('Should give the  object.address.home.addressLines[2]', function () {
          assert.equal(getIn(object,[ "address", "home", "addressLines","2"]), object.address.home.addressLines[2]);
    });
    it('Should give the null', function () {
          assert.equal(getIn(object,["hello", "none", "reve", "hello"]), null);
    }); 
  });
});
