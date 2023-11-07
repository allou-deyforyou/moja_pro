REMOVE DATABASE moja;

-- TABLE user
DEFINE TABLE user SCHEMAFULL
    PERMISSIONS
        FOR select,update,delete WHERE id = $auth.id;
DEFINE FIELD phone ON user TYPE string;
DEFINE FIELD agent ON user TYPE option<bool>;
DEFINE FIELD locked ON user TYPE bool DEFAULT false;
DEFINE FIELD last_sign ON user TYPE datetime DEFAULT time::now();
DEFINE FIELD created_at ON user TYPE datetime DEFAULT time::now();

-- TABLE works
DEFINE TABLE works SCHEMAFULL
    PERMISSIONS
		FOR select FULL
    	FOR create,update,delete WHERE $auth.id != null;
DEFINE FIELD in ON works TYPE record<user>;
DEFINE FIELD out ON works TYPE record<relay>;

-- TABLE located
DEFINE TABLE located SCHEMAFULL
    PERMISSIONS
		FOR select FULL
    	FOR create,update,delete WHERE $auth.id != null;
DEFINE FIELD in ON located TYPE record<relay>;
DEFINE FIELD out ON located TYPE record<country>;
DEFINE INDEX unique_relation ON located FIELDS in UNIQUE;

-- TABLE created
DEFINE TABLE created SCHEMAFULL
    PERMISSIONS
		FOR select FULL
    	FOR create,update,delete WHERE $auth.id != null;
DEFINE FIELD in ON created TYPE record<relay>;
DEFINE FIELD out ON created TYPE record<account>;
DEFINE FIELD balance ON created TYPE float;
DEFINE INDEX unique_relation ON created FIELDS in, out UNIQUE;

-- TABLE exists
DEFINE TABLE exists SCHEMAFULL
    PERMISSIONS
		FOR select FULL
    	FOR create,update,delete WHERE $auth.id != null;
DEFINE FIELD in ON exists TYPE record<account>;
DEFINE FIELD out ON exists TYPE record<country>;
DEFINE FIELD balance ON exists TYPE float;
DEFINE INDEX unique_relation ON exists FIELDS in, out UNIQUE;

-- TABLE relay
DEFINE TABLE relay SCHEMAFULL
    PERMISSIONS
		FOR select FULL
    	FOR create,update,delete WHERE owner = $auth.id;
DEFINE FIELD name ON relay TYPE string;
DEFINE FIELD locked ON relay TYPE bool DEFAULT false;
DEFINE FIELD image ON relay TYPE option<string>;
DEFINE FIELD owner ON relay TYPE record<user>;
DEFINE FIELD contacts ON relay TYPE option<array<string>>;
DEFINE FIELD location ON relay TYPE option<object>;
DEFINE FIELD created_at ON relay TYPE datetime DEFAULT time::now();

-- TABLE weekday
DEFINE TABLE weekday SCHEMAFULL;
DEFINE FIELD name ON weekday TYPE string;

-- TABLE account
DEFINE TABLE account SCHEMAFULL;
DEFINE FIELD name ON account TYPE string;
DEFINE FIELD cash ON account TYPE option<bool>;

-- TABLE country
DEFINE TABLE country SCHEMAFULL
	PERMISSIONS
		FOR select FULL
		FOR create,update,delete NONE;
DEFINE FIELD code ON country TYPE string;
DEFINE FIELD dialcode ON country TYPE string;
DEFINE INDEX unique_country ON country FIELDS code, dialcode UNIQUE;

-- SCOPE agent
DEFINE SCOPE agent SESSION 1d
	SIGNIN (
		SELECT * FROM type::thing('user',
			array::first(SELECT VALUE array::first(users).localId FROM
			http::post('https://identitytoolkit.googleapis.com/v1/accounts:lookup?key=AIzaSyARHj6HT_dix5FbsdYlf-H7Bv2uW_BV-U0', {'idToken': $idToken}))
		)
	)
	SIGNUP {
		LET $datetime = time::now();

		LET $user_created = CREATE ONLY type::thing('user', $uid) CONTENT {
			agent: true,
			phone: $phone,
            country: $country_id,
			last_sign: $datetime,
			created_at: $datetime,
		};

		LET $relay_created = CREATE ONLY relay CONTENT {
			name: $relay_name,
			created_at: $datetime,
			owner: $user_created.id,
		};

		LET $user_id = $user_created.id;
		LET $relay_id = $relay_created.id;

		RELATE $user_id->works->$relay_id;
		RELATE $relay_id->located->$country_id;

		RETURN $user_created;
	};

DEFINE FUNCTION fn::get_countries($ip: string) {
	LET $result = array::first(SELECT VALUE countryCode FROM http::get(string::concat('http://ip-api.com/json/', $ip)));
    RETURN SELECT *, (code == $result) as active FROM country;
};

DEFINE FUNCTION fn::search_place_by_query($query: string, $latitude: float, $longitude: float, $language: string) {
    RETURN function($query, $latitude, $longitude, $language) {
        const [query, latitude, longitude, language] = arguments;
        const response = await fetch(`https://photon.komoot.io/api?q=${query}&lat=${latitude}&lon=${longitude}&lang=${language}`);
        const data = await response.json();

        return data.features.map(item => {
            return {
                name: item.properties.name,
                city: item.properties.city,
                state: item.properties.state,
                country: item.properties.country,
                locality: item.properties.locality,
                position: {
                    latitude: item.geometry.coordinates[1],
                    longitude: item.geometry.coordinates[0],
                },
            };
        });
    };
};


DEFINE FUNCTION fn::search_place_by_point($latitude: float, $longitude: float, $language: string) {
	RETURN function($latitude, $longitude, $language) {
        const [latitude, longitude, language] = arguments;
        const response = await fetch(`https://photon.komoot.io/reverse?&lat=${latitude}&lon=${longitude}&lang=${language}`);
        const data = await response.json();

        return data.features.map(item => {
            return {
                name: item.properties.name,
                city: item.properties.city,
                state: item.properties.state,
                country: item.properties.country,
                locality: item.properties.locality,
                position: {
                    latitude: item.geometry.coordinates[1],
                    longitude: item.geometry.coordinates[0],
                },
            };
        });
    };
};

INSERT INTO account [
	{ name: 'Wave' },
	{ name: 'Orange Money' },
	{ name: 'MTN Money' },
	{ name: 'Moov Money' },
];

INSERT INTO country [
	{ code: 'CI', dialcode: '+225' },
];
