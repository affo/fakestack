BIGNUM=100000000

nova quota-class-update --instances $BIGNUM default
nova quota-class-update --cores $BIGNUM default
nova quota-class-update --ram $BIGNUM default