
    -- Initialize schema
    CREATE TABLE IF NOT EXISTS passages (
      id TEXT PRIMARY KEY,
      start_time TEXT NOT NULL,
      end_time TEXT NOT NULL,
      duration INTEGER NOT NULL,
      avg_speed REAL NOT NULL,
      max_speed REAL NOT NULL,
      distance REAL NOT NULL,
      start_lat REAL NOT NULL,
      start_lon REAL NOT NULL,
      end_lat REAL NOT NULL,
      end_lon REAL NOT NULL,
      description TEXT,
      name TEXT NOT NULL,
      route TEXT,
      export_timestamp TEXT,
      filename TEXT,
      query_metadata TEXT,
      encounters_filename TEXT,
      created_at INTEGER DEFAULT (unixepoch()),
      updated_at INTEGER DEFAULT (unixepoch())
    );

    CREATE TABLE IF NOT EXISTS passage_positions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      passage_id TEXT NOT NULL,
      time TEXT NOT NULL,
      lat REAL NOT NULL,
      lon REAL NOT NULL,
      speed REAL,
      heading REAL,
      distance REAL,
      FOREIGN KEY (passage_id) REFERENCES passages(id) ON DELETE CASCADE,
      UNIQUE(passage_id, time)
    );

    CREATE TABLE IF NOT EXISTS passage_locations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      passage_id TEXT NOT NULL,
      time TEXT NOT NULL,
      lat REAL NOT NULL,
      lon REAL NOT NULL,
      name TEXT,
      locality TEXT,
      administrative_area TEXT,
      country TEXT,
      country_code TEXT,
      formatted_address TEXT,
      points_of_interest TEXT,
      created_at INTEGER DEFAULT (unixepoch()),
      FOREIGN KEY (passage_id) REFERENCES passages(id) ON DELETE CASCADE
    );

    CREATE INDEX IF NOT EXISTS idx_passages_start_time ON passages(start_time);
    CREATE INDEX IF NOT EXISTS idx_passages_end_time ON passages(end_time);
    CREATE INDEX IF NOT EXISTS idx_passage_positions_passage_id ON passage_positions(passage_id);
    CREATE INDEX IF NOT EXISTS idx_passage_positions_time ON passage_positions(time);
    CREATE INDEX IF NOT EXISTS idx_passage_locations_passage_id ON passage_locations(passage_id);
    CREATE INDEX IF NOT EXISTS idx_passage_locations_time ON passage_locations(time);
  

        INSERT OR REPLACE INTO passages (
          id, start_time, end_time, duration, avg_speed, max_speed, distance,
          start_lat, start_lon, end_lat, end_lon, description, name, route,
          export_timestamp, filename, query_metadata, encounters_filename, updated_at
        ) VALUES (
          'passage_1730556000000',
          '2024-11-02T14:00:00Z',
          '2024-11-03T17:00:00Z',
          27,
          3.660102098651355,
          4.078847503373756,
          185.68164193608317,
          32.75885290156249,
          -79.86615029765629,
          29.911176010059105,
          -81.27866791086623,
          'Passage from 2024-11-02T14:00:00.000Z to 2024-11-03T17:00:00.000Z',
          'Passage passage_1730556000000',
          '32.76, -79.87 → 29.91, -81.28',
          '2025-08-15T18:56:05.758Z',
          'passage_2024-11-02_passage_1730556000000.json',
          NULL,
          NULL,
          unixepoch()
        );
      
DELETE FROM passage_positions WHERE passage_id = 'passage_1730556000000';

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1730556000000',
              '2024-11-02T14:00:00Z',
              32.78989943333334,
              -79.9105732,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1730556000000',
              '2024-11-02T14:15:00Z',
              32.7899096,
              -79.9106061,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1730556000000',
              '2024-11-02T14:30:00Z',
              32.78992165,
              -79.9106157,
              NULL,
              NULL,
              NULL
            );
          
DELETE FROM passage_locations WHERE passage_id = 'passage_1730556000000';

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1730556000000',
              '2024-11-02T14:00:00Z',
              32.78989943333334,
              -79.9105732,
              'Mount Pleasant',
              'Mount Pleasant',
              'South Carolina',
              'United States',
              'US',
              'Mount Pleasant, Charleston County, South Carolina, United States',
              '[]'
            );
          

        INSERT OR REPLACE INTO passages (
          id, start_time, end_time, duration, avg_speed, max_speed, distance,
          start_lat, start_lon, end_lat, end_lon, description, name, route,
          export_timestamp, filename, query_metadata, encounters_filename, updated_at
        ) VALUES (
          'passage_1731074400000',
          '2024-11-08T14:00:00Z',
          '2024-11-09T21:00:00Z',
          31,
          3.3673714708332354,
          3.795812701829886,
          200.39167223916564,
          29.893969061881574,
          -81.24254088146348,
          26.726590333132542,
          -80.04697743313267,
          'Passage from 2024-11-08T14:00:00.000Z to 2024-11-09T21:00:00.000Z',
          'Passage passage_1731074400000',
          '29.89, -81.24 → 26.73, -80.05',
          '2025-08-15T18:56:05.760Z',
          'passage_2024-11-08_passage_1731074400000.json',
          NULL,
          NULL,
          unixepoch()
        );
      
DELETE FROM passage_positions WHERE passage_id = 'passage_1731074400000';

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1731074400000',
              '2024-11-09T19:15:00Z',
              26.749225000000003,
              -80.04880788,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1731074400000',
              '2024-11-09T19:30:00Z',
              26.749200000000002,
              -80.0487857,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1731074400000',
              '2024-11-09T19:45:00Z',
              26.74922866,
              -80.04877618,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1731074400000',
              '2024-11-09T20:00:00Z',
              26.749220425000004,
              -80.04879655,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1731074400000',
              '2024-11-09T20:15:00Z',
              26.749241660000003,
              -80.04881252,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1731074400000',
              '2024-11-09T20:30:00Z',
              26.7492279,
              -80.0488307,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1731074400000',
              '2024-11-09T20:45:00Z',
              26.749232319999997,
              -80.04878987999999,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1731074400000',
              '2024-11-09T21:00:00Z',
              26.749235024999997,
              -80.048812375,
              NULL,
              NULL,
              NULL
            );
          
DELETE FROM passage_locations WHERE passage_id = 'passage_1731074400000';

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1731074400000',
              '2024-11-09T19:15:00Z',
              26.749225000000003,
              -80.04880788,
              'West Palm Beach',
              'West Palm Beach',
              'Florida',
              'United States',
              'US',
              'West Palm Beach, Palm Beach County, Florida, United States',
              '[]'
            );
          

        INSERT OR REPLACE INTO passages (
          id, start_time, end_time, duration, avg_speed, max_speed, distance,
          start_lat, start_lon, end_lat, end_lon, description, name, route,
          export_timestamp, filename, query_metadata, encounters_filename, updated_at
        ) VALUES (
          'passage_1731934800000',
          '2024-11-18T13:00:00Z',
          '2024-11-20T20:00:00Z',
          55,
          2.9895078352760867,
          3.5190671339984303,
          300.6611918251526,
          26.77664791545501,
          -79.95347961518583,
          23.506803703126877,
          -75.76273434991782,
          'Passage from 2024-11-18T13:00:00.000Z to 2024-11-20T20:00:00.000Z',
          'Passage passage_1731934800000',
          '26.78, -79.95 → 23.51, -75.76',
          '2025-08-15T18:56:05.761Z',
          'passage_2024-11-18_passage_1731934800000.json',
          NULL,
          NULL,
          unixepoch()
        );
      
DELETE FROM passage_positions WHERE passage_id = 'passage_1731934800000';

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1731934800000',
              '2024-11-18T22:00:00Z',
              26.5237383,
              -78.8022182,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1731934800000',
              '2024-11-18T22:15:00Z',
              26.52371336666667,
              -78.80225209999999,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1731934800000',
              '2024-11-18T22:30:00Z',
              26.523700566666665,
              -78.80230486666667,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1731934800000',
              '2024-11-18T22:45:00Z',
              26.5237029,
              -78.8023086,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1731934800000',
              '2024-11-18T23:00:00Z',
              26.523704019999997,
              -78.80229154,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1731934800000',
              '2024-11-18T23:15:00Z',
              26.5236329,
              -78.80230695,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1731934800000',
              '2024-11-18T23:30:00Z',
              26.5235117,
              -78.802299025,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1731934800000',
              '2024-11-18T23:45:00Z',
              26.52348202,
              -78.80231619999999,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1731934800000',
              '2024-11-19T00:00:00Z',
              26.523527339999998,
              -78.80231952,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1731934800000',
              '2024-11-19T00:15:00Z',
              26.52355268,
              -78.80232854,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1731934800000',
              '2024-11-19T00:30:00Z',
              26.52355334,
              -78.80233252000001,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1731934800000',
              '2024-11-19T00:45:00Z',
              26.523453340000003,
              -78.80230318000001,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1731934800000',
              '2024-11-19T01:00:00Z',
              26.523470000000003,
              -78.80230454,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1731934800000',
              '2024-11-19T01:15:00Z',
              26.523525340000003,
              -78.80231888,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1731934800000',
              '2024-11-19T01:30:00Z',
              26.523563324999998,
              -78.80231945,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1731934800000',
              '2024-11-19T01:45:00Z',
              26.523554679999997,
              -78.80231920000001,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1731934800000',
              '2024-11-19T02:00:00Z',
              26.523579679999994,
              -78.8023272,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1731934800000',
              '2024-11-19T02:15:00Z',
              26.52356955,
              -78.802300675,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1731934800000',
              '2024-11-19T02:45:00Z',
              26.5235033,
              -78.8022749,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1731934800000',
              '2024-11-19T03:00:00Z',
              26.5235833,
              -78.8022815,
              NULL,
              NULL,
              NULL
            );
          
DELETE FROM passage_locations WHERE passage_id = 'passage_1731934800000';

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1731934800000',
              '2024-11-18T22:00:00Z',
              26.5237383,
              -78.8022182,
              'West Grand Bahama',
              'West Grand Bahama',
              NULL,
              'The Bahamas',
              'BS',
              'West Grand Bahama, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1731934800000',
              '2024-11-18T22:30:00Z',
              26.523700566666665,
              -78.80230486666667,
              'West Grand Bahama',
              'West Grand Bahama',
              NULL,
              'The Bahamas',
              'BS',
              'West Grand Bahama, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1731934800000',
              '2024-11-18T23:30:00Z',
              26.5235117,
              -78.802299025,
              'West Grand Bahama',
              'West Grand Bahama',
              NULL,
              'The Bahamas',
              'BS',
              'West Grand Bahama, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1731934800000',
              '2024-11-19T00:30:00Z',
              26.52355334,
              -78.80233252000001,
              'West Grand Bahama',
              'West Grand Bahama',
              NULL,
              'The Bahamas',
              'BS',
              'West Grand Bahama, The Bahamas',
              '[]'
            );
          

        INSERT OR REPLACE INTO passages (
          id, start_time, end_time, duration, avg_speed, max_speed, distance,
          start_lat, start_lon, end_lat, end_lon, description, name, route,
          export_timestamp, filename, query_metadata, encounters_filename, updated_at
        ) VALUES (
          'passage_1736683200000',
          '2025-01-12T12:00:00Z',
          '2025-01-12T18:00:00Z',
          6,
          3.097070419713958,
          3.6986977622001063,
          26.18031857109483,
          23.4901126922201,
          -75.68733597938021,
          23.056667301671126,
          -75.73908638636121,
          'Passage from 2025-01-12T12:00:00.000Z to 2025-01-12T18:00:00.000Z',
          'Passage passage_1736683200000',
          '23.49, -75.69 → 23.06, -75.74',
          '2025-08-15T18:56:05.761Z',
          'passage_2025-01-12_passage_1736683200000.json',
          NULL,
          NULL,
          unixepoch()
        );
      
DELETE FROM passage_positions WHERE passage_id = 'passage_1736683200000';

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1736683200000',
              '2025-01-12T12:00:00Z',
              23.529808,
              -75.7682892,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1736683200000',
              '2025-01-12T12:15:00Z',
              23.529860425000003,
              -75.768287775,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1736683200000',
              '2025-01-12T12:30:00Z',
              23.529876979999994,
              -75.76829054,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1736683200000',
              '2025-01-12T12:45:00Z',
              23.5298525,
              -75.768289025,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1736683200000',
              '2025-01-12T13:00:00Z',
              23.52981998,
              -75.76828853999999,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1736683200000',
              '2025-01-12T13:15:00Z',
              23.52981166666667,
              -75.76828096666667,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1736683200000',
              '2025-01-12T13:30:00Z',
              23.5298183,
              -75.7682832,
              NULL,
              NULL,
              NULL
            );
          
DELETE FROM passage_locations WHERE passage_id = 'passage_1736683200000';

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1736683200000',
              '2025-01-12T12:00:00Z',
              23.529808,
              -75.7682892,
              'Exuma',
              'Exuma',
              NULL,
              'The Bahamas',
              'BS',
              'Exuma, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1736683200000',
              '2025-01-12T12:30:00Z',
              23.529876979999994,
              -75.76829054,
              'Exuma',
              'Exuma',
              NULL,
              'The Bahamas',
              'BS',
              'Exuma, The Bahamas',
              '[]'
            );
          

        INSERT OR REPLACE INTO passages (
          id, start_time, end_time, duration, avg_speed, max_speed, distance,
          start_lat, start_lon, end_lat, end_lon, description, name, route,
          export_timestamp, filename, query_metadata, encounters_filename, updated_at
        ) VALUES (
          'passage_1736712000000',
          '2025-01-12T20:00:00Z',
          '2025-01-12T21:00:00Z',
          1,
          3.0407035018309383,
          3.0984180638182743,
          3.472258096725667,
          22.94687439602076,
          -75.8519477683391,
          22.89294598613062,
          -75.87462505558551,
          'Passage from 2025-01-12T20:00:00.000Z to 2025-01-12T21:00:00.000Z',
          'Passage passage_1736712000000',
          '22.95, -75.85 → 22.89, -75.87',
          '2025-08-15T18:56:05.762Z',
          'passage_2025-01-12_passage_1736712000000.json',
          NULL,
          NULL,
          unixepoch()
        );
      
DELETE FROM passage_positions WHERE passage_id = 'passage_1736712000000';

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1736712000000',
              '2025-01-12T20:45:00Z',
              22.883520566666665,
              -75.86881043333334,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1736712000000',
              '2025-01-12T21:00:00Z',
              22.883512,
              -75.8688372,
              NULL,
              NULL,
              NULL
            );
          
DELETE FROM passage_locations WHERE passage_id = 'passage_1736712000000';

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1736712000000',
              '2025-01-12T20:45:00Z',
              22.883520566666665,
              -75.86881043333334,
              'Ragged Island',
              'Ragged Island',
              NULL,
              'The Bahamas',
              'BS',
              'Ragged Island, The Bahamas',
              '[]'
            );
          

        INSERT OR REPLACE INTO passages (
          id, start_time, end_time, duration, avg_speed, max_speed, distance,
          start_lat, start_lon, end_lat, end_lon, description, name, route,
          export_timestamp, filename, query_metadata, encounters_filename, updated_at
        ) VALUES (
          'passage_1736784000000',
          '2025-01-13T16:00:00Z',
          '2025-01-13T20:00:00Z',
          4,
          3.4213576875605582,
          3.5652922165365526,
          23.400306369249282,
          22.76387693717672,
          -75.91115303868538,
          22.380860274112415,
          -75.83307987825438,
          'Passage from 2025-01-13T16:00:00.000Z to 2025-01-13T20:00:00.000Z',
          'Passage passage_1736784000000',
          '22.76, -75.91 → 22.38, -75.83',
          '2025-08-15T18:56:05.762Z',
          'passage_2025-01-13_passage_1736784000000.json',
          NULL,
          NULL,
          unixepoch()
        );
      
DELETE FROM passage_positions WHERE passage_id = 'passage_1736784000000';

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1736784000000',
              '2025-01-13T17:45:00Z',
              22.477107845,
              -75.87603594,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1736784000000',
              '2025-01-13T18:00:00Z',
              22.497322641379316,
              -75.87977435172414,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1736784000000',
              '2025-01-13T18:15:00Z',
              22.520311034482763,
              -75.88619733793104,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1736784000000',
              '2025-01-13T18:30:00Z',
              22.54531828275861,
              -75.8943774551724,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1736784000000',
              '2025-01-13T18:45:00Z',
              22.561126442857148,
              -75.89896152857143,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1736784000000',
              '2025-01-13T17:15:00Z',
              22.43431355,
              -75.86700611250001,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1736784000000',
              '2025-01-13T17:30:00Z',
              22.45044512692308,
              -75.87050441923076,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1736784000000',
              '2025-01-13T17:45:00Z',
              22.4652373125,
              -75.87371133750001,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1736784000000',
              '2025-01-13T18:45:00Z',
              22.573872499999997,
              -75.90264236818182,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1736784000000',
              '2025-01-13T19:00:00Z',
              22.595947777777774,
              -75.9072064777778,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1736784000000',
              '2025-01-13T19:15:00Z',
              22.62094691111111,
              -75.91140807777778,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1736784000000',
              '2025-01-13T19:30:00Z',
              22.638881339999998,
              -75.91448954,
              NULL,
              NULL,
              NULL
            );
          
DELETE FROM passage_locations WHERE passage_id = 'passage_1736784000000';

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1736784000000',
              '2025-01-13T17:15:00Z',
              22.43431355,
              -75.86700611250001,
              'Ragged Island',
              'Ragged Island',
              NULL,
              'The Bahamas',
              'BS',
              'Ragged Island, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1736784000000',
              '2025-01-13T17:30:00Z',
              22.45044512692308,
              -75.87050441923076,
              'Ragged Island',
              'Ragged Island',
              NULL,
              'The Bahamas',
              'BS',
              'Ragged Island, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1736784000000',
              '2025-01-13T18:00:00Z',
              22.497322641379316,
              -75.87977435172414,
              'Ragged Island',
              'Ragged Island',
              NULL,
              'The Bahamas',
              'BS',
              'Ragged Island, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1736784000000',
              '2025-01-13T18:30:00Z',
              22.54531828275861,
              -75.8943774551724,
              'Ragged Island',
              'Ragged Island',
              NULL,
              'The Bahamas',
              'BS',
              'Ragged Island, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1736784000000',
              '2025-01-13T18:45:00Z',
              22.561126442857148,
              -75.89896152857143,
              'Ragged Island',
              'Ragged Island',
              NULL,
              'The Bahamas',
              'BS',
              'Ragged Island, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1736784000000',
              '2025-01-13T19:15:00Z',
              22.62094691111111,
              -75.91140807777778,
              'Ragged Island',
              'Ragged Island',
              NULL,
              'The Bahamas',
              'BS',
              'Ragged Island, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1736784000000',
              '2025-01-13T19:30:00Z',
              22.638881339999998,
              -75.91448954,
              'Ragged Island',
              'Ragged Island',
              NULL,
              'The Bahamas',
              'BS',
              'Ragged Island, The Bahamas',
              '[]'
            );
          

        INSERT OR REPLACE INTO passages (
          id, start_time, end_time, duration, avg_speed, max_speed, distance,
          start_lat, start_lon, end_lat, end_lon, description, name, route,
          export_timestamp, filename, query_metadata, encounters_filename, updated_at
        ) VALUES (
          'passage_1736949600000',
          '2025-01-15T14:00:00Z',
          '2025-01-15T15:00:00Z',
          1,
          2.4112795447764186,
          3.3914116379310526,
          0.8701575346775049,
          22.25046827021506,
          -75.76835968166688,
          22.252701493808658,
          -75.75288772719718,
          'Passage from 2025-01-15T14:00:00.000Z to 2025-01-15T15:00:00.000Z',
          'Passage passage_1736949600000',
          '22.25, -75.77 → 22.25, -75.75',
          '2025-08-15T18:56:05.763Z',
          'passage_2025-01-15_passage_1736949600000.json',
          NULL,
          NULL,
          unixepoch()
        );
      
DELETE FROM passage_positions WHERE passage_id = 'passage_1736949600000';

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1736949600000',
              '2025-01-15T14:00:00Z',
              22.247855424999997,
              -75.75255652499999,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1736949600000',
              '2025-01-15T14:15:00Z',
              22.24785066,
              -75.75255586,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1736949600000',
              '2025-01-15T14:30:00Z',
              22.247836250000002,
              -75.7525332,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1736949600000',
              '2025-01-15T14:45:00Z',
              22.247827659999995,
              -75.75251588,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1736949600000',
              '2025-01-15T15:00:00Z',
              22.247835025,
              -75.7525282,
              NULL,
              NULL,
              NULL
            );
          
DELETE FROM passage_locations WHERE passage_id = 'passage_1736949600000';

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1736949600000',
              '2025-01-15T14:00:00Z',
              22.247855424999997,
              -75.75255652499999,
              'Ragged Island',
              'Ragged Island',
              NULL,
              'The Bahamas',
              'BS',
              'Ragged Island, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1736949600000',
              '2025-01-15T14:30:00Z',
              22.247836250000002,
              -75.7525332,
              'Ragged Island',
              'Ragged Island',
              NULL,
              'The Bahamas',
              'BS',
              'Ragged Island, The Bahamas',
              '[]'
            );
          

        INSERT OR REPLACE INTO passages (
          id, start_time, end_time, duration, avg_speed, max_speed, distance,
          start_lat, start_lon, end_lat, end_lon, description, name, route,
          export_timestamp, filename, query_metadata, encounters_filename, updated_at
        ) VALUES (
          'passage_1737309600000',
          '2025-01-19T18:00:00Z',
          '2025-01-19T19:00:00Z',
          1,
          2.4934470834234386,
          2.540789045553116,
          2.9960541035864616,
          22.294928064336204,
          -75.82390884029853,
          22.315615283198213,
          -75.77482575613185,
          'Passage from 2025-01-19T18:00:00.000Z to 2025-01-19T19:00:00.000Z',
          'Passage passage_1737309600000',
          '22.29, -75.82 → 22.32, -75.77',
          '2025-08-15T18:56:05.764Z',
          'passage_2025-01-19_passage_1737309600000.json',
          NULL,
          NULL,
          unixepoch()
        );
      
DELETE FROM passage_locations WHERE passage_id = 'passage_1737309600000';

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1737309600000',
              '2025-01-19T18:00:00Z',
              22.294928064336204,
              -75.82390884029853,
              'Ragged Island',
              'Ragged Island',
              NULL,
              'The Bahamas',
              'BS',
              'Ragged Island, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1737309600000',
              '2025-01-19T19:00:00Z',
              22.315615283198213,
              -75.77482575613185,
              'Ragged Island',
              'Ragged Island',
              NULL,
              'The Bahamas',
              'BS',
              'Ragged Island, The Bahamas',
              '[]'
            );
          

        INSERT OR REPLACE INTO passages (
          id, start_time, end_time, duration, avg_speed, max_speed, distance,
          start_lat, start_lon, end_lat, end_lon, description, name, route,
          export_timestamp, filename, query_metadata, encounters_filename, updated_at
        ) VALUES (
          'passage_1737464400000',
          '2025-01-21T13:00:00Z',
          '2025-01-21T18:00:00Z',
          5,
          3.2874235574765227,
          4.134211093160978,
          31.27257265621371,
          22.360998793502983,
          -75.8176198790471,
          22.879496009189694,
          -75.87128645840122,
          'Passage from 2025-01-21T13:00:00.000Z to 2025-01-21T18:00:00.000Z',
          'Passage passage_1737464400000',
          '22.36, -75.82 → 22.88, -75.87',
          '2025-08-15T18:56:05.764Z',
          'passage_2025-01-21_passage_1737464400000.json',
          NULL,
          NULL,
          unixepoch()
        );
      
DELETE FROM passage_positions WHERE passage_id = 'passage_1737464400000';

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1737464400000',
              '2025-01-21T16:15:00Z',
              21.53141,
              -76.4554115,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1737464400000',
              '2025-01-21T16:30:00Z',
              21.527745,
              -76.4461482,
              NULL,
              NULL,
              NULL
            );
          
DELETE FROM passage_locations WHERE passage_id = 'passage_1737464400000';

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1737464400000',
              '2025-01-21T16:15:00Z',
              21.53141,
              -76.4554115,
              'Las Tunas',
              NULL,
              'Las Tunas',
              'Cuba',
              'CU',
              'Las Tunas, Cuba',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1737464400000',
              '2025-01-21T16:30:00Z',
              21.527745,
              -76.4461482,
              'Las Tunas',
              NULL,
              'Las Tunas',
              'Cuba',
              'CU',
              'Las Tunas, Cuba',
              '[]'
            );
          

        INSERT OR REPLACE INTO passages (
          id, start_time, end_time, duration, avg_speed, max_speed, distance,
          start_lat, start_lon, end_lat, end_lon, description, name, route,
          export_timestamp, filename, query_metadata, encounters_filename, updated_at
        ) VALUES (
          'passage_1737554400000',
          '2025-01-22T14:00:00Z',
          '2025-01-22T21:00:00Z',
          7,
          3.366140656925701,
          3.693111709286758,
          30.017094856435648,
          23.001652611834313,
          -75.79774687136103,
          23.496845541956883,
          -75.7228793718076,
          'Passage from 2025-01-22T14:00:00.000Z to 2025-01-22T21:00:00.000Z',
          'Passage passage_1737554400000',
          '23.00, -75.80 → 23.50, -75.72',
          '2025-08-15T18:56:05.765Z',
          'passage_2025-01-22_passage_1737554400000.json',
          NULL,
          NULL,
          unixepoch()
        );
      
DELETE FROM passage_locations WHERE passage_id = 'passage_1737554400000';

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1737554400000',
              '2025-01-22T14:00:00Z',
              23.001652611834313,
              -75.79774687136103,
              'Exuma',
              'Exuma',
              NULL,
              'The Bahamas',
              'BS',
              'Exuma, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1737554400000',
              '2025-01-22T21:00:00Z',
              23.496845541956883,
              -75.7228793718076,
              'Exuma',
              'Exuma',
              NULL,
              'The Bahamas',
              'BS',
              'Exuma, The Bahamas',
              '[]'
            );
          

        INSERT OR REPLACE INTO passages (
          id, start_time, end_time, duration, avg_speed, max_speed, distance,
          start_lat, start_lon, end_lat, end_lon, description, name, route,
          export_timestamp, filename, query_metadata, encounters_filename, updated_at
        ) VALUES (
          'passage_1738414800000',
          '2025-02-01T13:00:00Z',
          '2025-02-01T20:00:00Z',
          7,
          2.834022129158232,
          3.8253002962563416,
          27.74235594564996,
          23.489752339456757,
          -75.69310681258031,
          23.02819552340905,
          -75.71659553132194,
          'Passage from 2025-02-01T13:00:00.000Z to 2025-02-01T20:00:00.000Z',
          'Passage passage_1738414800000',
          '23.49, -75.69 → 23.03, -75.72',
          '2025-08-15T18:56:05.765Z',
          'passage_2025-02-01_passage_1738414800000.json',
          NULL,
          NULL,
          unixepoch()
        );
      
DELETE FROM passage_positions WHERE passage_id = 'passage_1738414800000';

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738414800000',
              '2025-02-01T13:00:00Z',
              23.505823085714287,
              -75.76347342857142,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738414800000',
              '2025-02-01T13:15:00Z',
              23.505835425,
              -75.76344695,
              NULL,
              NULL,
              NULL
            );
          
DELETE FROM passage_locations WHERE passage_id = 'passage_1738414800000';

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1738414800000',
              '2025-02-01T13:00:00Z',
              23.505823085714287,
              -75.76347342857142,
              'Exuma',
              'Exuma',
              NULL,
              'The Bahamas',
              'BS',
              'Exuma, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1738414800000',
              '2025-02-01T13:15:00Z',
              23.505835425,
              -75.76344695,
              'Exuma',
              'Exuma',
              NULL,
              'The Bahamas',
              'BS',
              'Exuma, The Bahamas',
              '[]'
            );
          

        INSERT OR REPLACE INTO passages (
          id, start_time, end_time, duration, avg_speed, max_speed, distance,
          start_lat, start_lon, end_lat, end_lon, description, name, route,
          export_timestamp, filename, query_metadata, encounters_filename, updated_at
        ) VALUES (
          'passage_1738504800000',
          '2025-02-02T14:00:00Z',
          '2025-02-02T20:00:00Z',
          6,
          3.3573265884631094,
          3.8164172862453607,
          35.571444283636,
          22.94882858297518,
          -75.84131925652898,
          22.356830230456264,
          -75.8160387308259,
          'Passage from 2025-02-02T14:00:00.000Z to 2025-02-02T20:00:00.000Z',
          'Passage passage_1738504800000',
          '22.95, -75.84 → 22.36, -75.82',
          '2025-08-15T18:56:05.765Z',
          'passage_2025-02-02_passage_1738504800000.json',
          NULL,
          NULL,
          unixepoch()
        );
      
DELETE FROM passage_positions WHERE passage_id = 'passage_1738504800000';

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738504800000',
              '2025-02-02T18:00:00Z',
              22.4282433,
              -75.836074,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738504800000',
              '2025-02-02T18:15:00Z',
              22.4282233,
              -75.8360782,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738504800000',
              '2025-02-02T18:30:00Z',
              22.428239575,
              -75.83606695,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738504800000',
              '2025-02-02T18:45:00Z',
              22.42824665,
              -75.8360332,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738504800000',
              '2025-02-02T19:00:00Z',
              22.42875918333333,
              -75.83471153333333,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738504800000',
              '2025-02-02T19:15:00Z',
              22.4288325,
              -75.8344457,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738504800000',
              '2025-02-02T19:30:00Z',
              22.428848325000004,
              -75.8344482,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738504800000',
              '2025-02-02T19:45:00Z',
              22.4288417,
              -75.8344515,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738504800000',
              '2025-02-02T20:00:00Z',
              22.428825,
              -75.8344549,
              NULL,
              NULL,
              NULL
            );
          
DELETE FROM passage_locations WHERE passage_id = 'passage_1738504800000';

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1738504800000',
              '2025-02-02T18:00:00Z',
              22.4282433,
              -75.836074,
              'Ragged Island',
              'Ragged Island',
              NULL,
              'The Bahamas',
              'BS',
              'Ragged Island, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1738504800000',
              '2025-02-02T19:00:00Z',
              22.42875918333333,
              -75.83471153333333,
              'Ragged Island',
              'Ragged Island',
              NULL,
              'The Bahamas',
              'BS',
              'Ragged Island, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1738504800000',
              '2025-02-02T19:30:00Z',
              22.428848325000004,
              -75.8344482,
              'Ragged Island',
              'Ragged Island',
              NULL,
              'The Bahamas',
              'BS',
              'Ragged Island, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1738504800000',
              '2025-02-02T20:00:00Z',
              22.428825,
              -75.8344549,
              'Ragged Island',
              'Ragged Island',
              NULL,
              'The Bahamas',
              'BS',
              'Ragged Island, The Bahamas',
              '[]'
            );
          

        INSERT OR REPLACE INTO passages (
          id, start_time, end_time, duration, avg_speed, max_speed, distance,
          start_lat, start_lon, end_lat, end_lon, description, name, route,
          export_timestamp, filename, query_metadata, encounters_filename, updated_at
        ) VALUES (
          'passage_1738933200000',
          '2025-02-07T13:00:00Z',
          '2025-02-07T19:00:00Z',
          6,
          3.3612077475561537,
          3.8497300516077786,
          33.01576353778418,
          22.470936295321636,
          -75.86559513157891,
          23.01309650420712,
          -75.76596041165048,
          'Passage from 2025-02-07T13:00:00.000Z to 2025-02-07T19:00:00.000Z',
          'Passage passage_1738933200000',
          '22.47, -75.87 → 23.01, -75.77',
          '2025-08-15T18:56:05.766Z',
          'passage_2025-02-07_passage_1738933200000.json',
          NULL,
          NULL,
          unixepoch()
        );
      
DELETE FROM passage_positions WHERE passage_id = 'passage_1738933200000';

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T19:00:00Z',
              22.941295625,
              -75.84607195000001,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T18:00:00Z',
              22.848140637500002,
              -75.89121068749999,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T18:15:00Z',
              22.872614900000002,
              -75.88552624117646,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T18:30:00Z',
              22.899923018750002,
              -75.87936496875,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T18:45:00Z',
              22.91826611333333,
              -75.86881298,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T19:00:00Z',
              22.92918915,
              -75.85748989999999,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T17:45:00Z',
              22.8206579125,
              -75.8978571625,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T18:00:00Z',
              22.833983,
              -75.89446253999999,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T17:15:00Z',
              22.76402434,
              -75.91649070499999,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T17:30:00Z',
              22.789119411764705,
              -75.90853162941175,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T17:45:00Z',
              22.80484666,
              -75.90191187,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T13:00:00Z',
              22.367814433333333,
              -75.82161206666666,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T13:15:00Z',
              22.367797075,
              -75.821614875,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T13:30:00Z',
              22.3677779,
              -75.82162155,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T13:45:00Z',
              22.367800533333334,
              -75.82159986666666,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T14:00:00Z',
              22.368723066666664,
              -75.82599265,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T14:45:00Z',
              22.4698683,
              -75.8721899,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T15:00:00Z',
              22.486666590476187,
              -75.87799192857142,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T15:15:00Z',
              22.517992329999995,
              -75.88813328,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T15:30:00Z',
              22.53937499,
              -75.8967407,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T14:00:00Z',
              22.378455364285713,
              -75.83321057857144,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T14:15:00Z',
              22.40023113181818,
              -75.84096252727271,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T14:30:00Z',
              22.428073009523807,
              -75.85197288571429,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T14:45:00Z',
              22.45578796666667,
              -75.86558071111112,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T15:30:00Z',
              22.555192287500002,
              -75.901730275,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T15:45:00Z',
              22.562582499999998,
              -75.90410485000001,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T15:45:00Z',
              22.575067666666662,
              -75.90819076,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T16:00:00Z',
              22.606246476470588,
              -75.91639279411763,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T16:15:00Z',
              22.638752803999996,
              -75.917196672,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T16:30:00Z',
              22.65618415,
              -75.91664485000001,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T16:30:00Z',
              22.6742098,
              -75.91740095294118,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T16:45:00Z',
              22.7018794375,
              -75.9167901375,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T17:00:00Z',
              22.732878073684216,
              -75.91700714736844,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1738933200000',
              '2025-02-07T17:15:00Z',
              22.75031833333333,
              -75.91707986666667,
              NULL,
              NULL,
              NULL
            );
          
DELETE FROM passage_locations WHERE passage_id = 'passage_1738933200000';

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1738933200000',
              '2025-02-07T13:00:00Z',
              22.367814433333333,
              -75.82161206666666,
              'Ragged Island',
              'Ragged Island',
              NULL,
              'The Bahamas',
              'BS',
              'Ragged Island, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1738933200000',
              '2025-02-07T14:00:00Z',
              22.368723066666664,
              -75.82599265,
              'Ragged Island',
              'Ragged Island',
              NULL,
              'The Bahamas',
              'BS',
              'Ragged Island, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1738933200000',
              '2025-02-07T14:30:00Z',
              22.428073009523807,
              -75.85197288571429,
              'Ragged Island',
              'Ragged Island',
              NULL,
              'The Bahamas',
              'BS',
              'Ragged Island, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1738933200000',
              '2025-02-07T15:00:00Z',
              22.486666590476187,
              -75.87799192857142,
              'Ragged Island',
              'Ragged Island',
              NULL,
              'The Bahamas',
              'BS',
              'Ragged Island, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1738933200000',
              '2025-02-07T15:30:00Z',
              22.53937499,
              -75.8967407,
              'Ragged Island',
              'Ragged Island',
              NULL,
              'The Bahamas',
              'BS',
              'Ragged Island, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1738933200000',
              '2025-02-07T16:00:00Z',
              22.606246476470588,
              -75.91639279411763,
              'Ragged Island',
              'Ragged Island',
              NULL,
              'The Bahamas',
              'BS',
              'Ragged Island, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1738933200000',
              '2025-02-07T16:30:00Z',
              22.65618415,
              -75.91664485000001,
              'Ragged Island',
              'Ragged Island',
              NULL,
              'The Bahamas',
              'BS',
              'Ragged Island, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1738933200000',
              '2025-02-07T17:00:00Z',
              22.732878073684216,
              -75.91700714736844,
              'Ragged Island',
              'Ragged Island',
              NULL,
              'The Bahamas',
              'BS',
              'Ragged Island, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1738933200000',
              '2025-02-07T17:30:00Z',
              22.789119411764705,
              -75.90853162941175,
              'Ragged Island',
              'Ragged Island',
              NULL,
              'The Bahamas',
              'BS',
              'Ragged Island, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1738933200000',
              '2025-02-07T18:00:00Z',
              22.848140637500002,
              -75.89121068749999,
              'Ragged Island',
              'Ragged Island',
              NULL,
              'The Bahamas',
              'BS',
              'Ragged Island, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1738933200000',
              '2025-02-07T18:30:00Z',
              22.899923018750002,
              -75.87936496875,
              'Ragged Island',
              'Ragged Island',
              NULL,
              'The Bahamas',
              'BS',
              'Ragged Island, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1738933200000',
              '2025-02-07T19:00:00Z',
              22.92918915,
              -75.85748989999999,
              'Ragged Island',
              'Ragged Island',
              NULL,
              'The Bahamas',
              'BS',
              'Ragged Island, The Bahamas',
              '[]'
            );
          

        INSERT OR REPLACE INTO passages (
          id, start_time, end_time, duration, avg_speed, max_speed, distance,
          start_lat, start_lon, end_lat, end_lon, description, name, route,
          export_timestamp, filename, query_metadata, encounters_filename, updated_at
        ) VALUES (
          'passage_1739102400000',
          '2025-02-09T12:00:00Z',
          '2025-02-09T22:00:00Z',
          10,
          2.8829841652470765,
          3.4070681642137823,
          26.308711897061414,
          23.070568346808553,
          -75.6865368037927,
          23.505628724014123,
          -75.7433879886619,
          'Passage from 2025-02-09T12:00:00.000Z to 2025-02-09T22:00:00.000Z',
          'Passage passage_1739102400000',
          '23.07, -75.69 → 23.51, -75.74',
          '2025-08-15T18:56:05.766Z',
          'passage_2025-02-09_passage_1739102400000.json',
          NULL,
          NULL,
          unixepoch()
        );
      
DELETE FROM passage_positions WHERE passage_id = 'passage_1739102400000';

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1739102400000',
              '2025-02-09T17:15:00Z',
              23.5069117,
              -75.1656165,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1739102400000',
              '2025-02-09T17:30:00Z',
              23.5131717,
              -75.16946405,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1739102400000',
              '2025-02-09T17:30:00Z',
              23.5237583,
              -75.1759249,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1739102400000',
              '2025-02-09T18:00:00Z',
              23.558405825,
              -75.197126525,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1739102400000',
              '2025-02-09T18:15:00Z',
              23.5814567,
              -75.2112315,
              NULL,
              NULL,
              NULL
            );
          
DELETE FROM passage_locations WHERE passage_id = 'passage_1739102400000';

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1739102400000',
              '2025-02-09T17:15:00Z',
              23.5069117,
              -75.1656165,
              'Long Island',
              'Long Island',
              NULL,
              'The Bahamas',
              'BS',
              'Long Island, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1739102400000',
              '2025-02-09T17:30:00Z',
              23.5131717,
              -75.16946405,
              'Long Island',
              'Long Island',
              NULL,
              'The Bahamas',
              'BS',
              'Long Island, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1739102400000',
              '2025-02-09T18:00:00Z',
              23.558405825,
              -75.197126525,
              'Long Island',
              'Long Island',
              NULL,
              'The Bahamas',
              'BS',
              'Long Island, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1739102400000',
              '2025-02-09T18:15:00Z',
              23.5814567,
              -75.2112315,
              'Long Island',
              'Long Island',
              NULL,
              'The Bahamas',
              'BS',
              'Long Island, The Bahamas',
              '[]'
            );
          

        INSERT OR REPLACE INTO passages (
          id, start_time, end_time, duration, avg_speed, max_speed, distance,
          start_lat, start_lon, end_lat, end_lon, description, name, route,
          export_timestamp, filename, query_metadata, encounters_filename, updated_at
        ) VALUES (
          'passage_1742925600000',
          '2025-03-25T18:00:00Z',
          '2025-03-25T19:00:00Z',
          1,
          1.3573024217031677,
          1.5058637152777838,
          0.37217334286895076,
          23.51173530948271,
          -75.74981025639354,
          23.51604470357981,
          -75.7546694291828,
          'Passage from 2025-03-25T18:00:00.000Z to 2025-03-25T19:00:00.000Z',
          'Passage passage_1742925600000',
          '23.51, -75.75 → 23.52, -75.75',
          '2025-08-15T18:56:05.767Z',
          'passage_2025-03-25_passage_1742925600000.json',
          NULL,
          NULL,
          unixepoch()
        );
      
DELETE FROM passage_locations WHERE passage_id = 'passage_1742925600000';

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1742925600000',
              '2025-03-25T18:00:00Z',
              23.51173530948271,
              -75.74981025639354,
              'Exuma',
              'Exuma',
              NULL,
              'The Bahamas',
              'BS',
              'Exuma, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1742925600000',
              '2025-03-25T19:00:00Z',
              23.51604470357981,
              -75.7546694291828,
              'Exuma',
              'Exuma',
              NULL,
              'The Bahamas',
              'BS',
              'Exuma, The Bahamas',
              '[]'
            );
          

        INSERT OR REPLACE INTO passages (
          id, start_time, end_time, duration, avg_speed, max_speed, distance,
          start_lat, start_lon, end_lat, end_lon, description, name, route,
          export_timestamp, filename, query_metadata, encounters_filename, updated_at
        ) VALUES (
          'passage_1744282800000',
          '2025-04-10T11:00:00Z',
          '2025-04-10T19:00:00Z',
          8,
          2.553195104908747,
          3.4360122968818394,
          29.059032326853426,
          23.489737539378876,
          -75.69165761863351,
          23.007186259797916,
          -75.73225553474724,
          'Passage from 2025-04-10T11:00:00.000Z to 2025-04-10T19:00:00.000Z',
          'Passage passage_1744282800000',
          '23.49, -75.69 → 23.01, -75.73',
          '2025-08-15T18:56:05.767Z',
          'passage_2025-04-10_passage_1744282800000.json',
          NULL,
          NULL,
          unixepoch()
        );
      
DELETE FROM passage_locations WHERE passage_id = 'passage_1744282800000';

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1744282800000',
              '2025-04-10T11:00:00Z',
              23.489737539378876,
              -75.69165761863351,
              'Exuma',
              'Exuma',
              NULL,
              'The Bahamas',
              'BS',
              'Exuma, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1744282800000',
              '2025-04-10T19:00:00Z',
              23.007186259797916,
              -75.73225553474724,
              'Exuma',
              'Exuma',
              NULL,
              'The Bahamas',
              'BS',
              'Exuma, The Bahamas',
              '[]'
            );
          

        INSERT OR REPLACE INTO passages (
          id, start_time, end_time, duration, avg_speed, max_speed, distance,
          start_lat, start_lon, end_lat, end_lon, description, name, route,
          export_timestamp, filename, query_metadata, encounters_filename, updated_at
        ) VALUES (
          'passage_1744405200000',
          '2025-04-11T21:00:00Z',
          '2025-04-11T23:00:00Z',
          2,
          1.969710969180812,
          3.214057084607553,
          7.738446257650274,
          22.991939989270396,
          -75.80343200472103,
          22.878823804378474,
          -75.87051413463627,
          'Passage from 2025-04-11T21:00:00.000Z to 2025-04-11T23:00:00.000Z',
          'Passage passage_1744405200000',
          '22.99, -75.80 → 22.88, -75.87',
          '2025-08-15T18:56:05.767Z',
          'passage_2025-04-11_passage_1744405200000.json',
          NULL,
          NULL,
          unixepoch()
        );
      
DELETE FROM passage_positions WHERE passage_id = 'passage_1744405200000';

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1744405200000',
              '2025-04-11T21:00:00Z',
              23.003022899999998,
              -75.73387655,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1744405200000',
              '2025-04-11T21:15:00Z',
              23.00304,
              -75.73387930000001,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1744405200000',
              '2025-04-11T21:30:00Z',
              23.003015339999997,
              -75.73387854,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1744405200000',
              '2025-04-11T21:45:00Z',
              23.003057233333333,
              -75.7338832,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1744405200000',
              '2025-04-11T22:00:00Z',
              23.00307665,
              -75.7338832,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1744405200000',
              '2025-04-11T22:15:00Z',
              23.00311432,
              -75.73391919999999,
              NULL,
              NULL,
              NULL
            );
          
DELETE FROM passage_locations WHERE passage_id = 'passage_1744405200000';

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1744405200000',
              '2025-04-11T21:00:00Z',
              23.003022899999998,
              -75.73387655,
              'Exuma',
              'Exuma',
              NULL,
              'The Bahamas',
              'BS',
              'Exuma, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1744405200000',
              '2025-04-11T21:45:00Z',
              23.003057233333333,
              -75.7338832,
              'Exuma',
              'Exuma',
              NULL,
              'The Bahamas',
              'BS',
              'Exuma, The Bahamas',
              '[]'
            );
          

        INSERT OR REPLACE INTO passages (
          id, start_time, end_time, duration, avg_speed, max_speed, distance,
          start_lat, start_lon, end_lat, end_lon, description, name, route,
          export_timestamp, filename, query_metadata, encounters_filename, updated_at
        ) VALUES (
          'passage_1744466400000',
          '2025-04-12T14:00:00Z',
          '2025-04-12T21:00:00Z',
          7,
          3.4640230223732593,
          3.7654686346864468,
          38.77900566417904,
          23.02078357922703,
          -75.75870236980677,
          23.34484369615384,
          -75.1509230397436,
          'Passage from 2025-04-12T14:00:00.000Z to 2025-04-12T21:00:00.000Z',
          'Passage passage_1744466400000',
          '23.02, -75.76 → 23.34, -75.15',
          '2025-08-15T18:56:05.767Z',
          'passage_2025-04-12_passage_1744466400000.json',
          NULL,
          NULL,
          unixepoch()
        );
      
DELETE FROM passage_positions WHERE passage_id = 'passage_1744466400000';

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1744466400000',
              '2025-04-12T18:45:00Z',
              23.34518,
              -75.1884915,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1744466400000',
              '2025-04-12T19:00:00Z',
              23.34453834,
              -75.17458153999999,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1744466400000',
              '2025-04-12T19:15:00Z',
              23.343786633333334,
              -75.16001263333334,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1744466400000',
              '2025-04-12T19:15:00Z',
              23.346734433333335,
              -75.15004766666668,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1744466400000',
              '2025-04-12T19:30:00Z',
              23.35461915,
              -75.13809735833333,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1744466400000',
              '2025-04-12T19:45:00Z',
              23.35738415,
              -75.13564985,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1744466400000',
              '2025-04-12T20:00:00Z',
              23.357377233333334,
              -75.13559763333333,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1744466400000',
              '2025-04-12T20:15:00Z',
              23.35738585,
              -75.13564737499999,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1744466400000',
              '2025-04-12T20:30:00Z',
              23.357385,
              -75.13559186,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1744466400000',
              '2025-04-12T20:45:00Z',
              23.357383900000002,
              -75.13555709999999,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1744466400000',
              '2025-04-12T21:00:00Z',
              23.357376675,
              -75.135563225,
              NULL,
              NULL,
              NULL
            );
          
DELETE FROM passage_locations WHERE passage_id = 'passage_1744466400000';

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1744466400000',
              '2025-04-12T18:45:00Z',
              23.34518,
              -75.1884915,
              'Long Island',
              'Long Island',
              NULL,
              'The Bahamas',
              'BS',
              'Long Island, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1744466400000',
              '2025-04-12T19:00:00Z',
              23.34453834,
              -75.17458153999999,
              'Long Island',
              'Long Island',
              NULL,
              'The Bahamas',
              'BS',
              'Long Island, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1744466400000',
              '2025-04-12T19:30:00Z',
              23.35461915,
              -75.13809735833333,
              'Long Island',
              'Long Island',
              NULL,
              'The Bahamas',
              'BS',
              'Long Island, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1744466400000',
              '2025-04-12T20:00:00Z',
              23.357377233333334,
              -75.13559763333333,
              'Long Island',
              'Long Island',
              NULL,
              'The Bahamas',
              'BS',
              'Long Island, The Bahamas',
              '[]'
            );
          

        INSERT OR REPLACE INTO passages (
          id, start_time, end_time, duration, avg_speed, max_speed, distance,
          start_lat, start_lon, end_lat, end_lon, description, name, route,
          export_timestamp, filename, query_metadata, encounters_filename, updated_at
        ) VALUES (
          'passage_1745251200000',
          '2025-04-21T16:00:00Z',
          '2025-04-21T20:00:00Z',
          4,
          2.5375726665586256,
          3.190615133369616,
          16.422683220828485,
          23.402671718473872,
          -75.21547537389556,
          23.652774011455687,
          -75.33626861162766,
          'Passage from 2025-04-21T16:00:00.000Z to 2025-04-21T20:00:00.000Z',
          'Passage passage_1745251200000',
          '23.40, -75.22 → 23.65, -75.34',
          '2025-08-15T18:56:05.768Z',
          'passage_2025-04-21_passage_1745251200000.json',
          NULL,
          NULL,
          unixepoch()
        );
      
DELETE FROM passage_positions WHERE passage_id = 'passage_1745251200000';

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1745251200000',
              '2025-04-21T17:00:00Z',
              23.43588,
              -75.5302049,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1745251200000',
              '2025-04-21T16:00:00Z',
              23.422189680000002,
              -75.43978571,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1745251200000',
              '2025-04-21T16:15:00Z',
              23.423038215384615,
              -75.46208025384615,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1745251200000',
              '2025-04-21T16:30:00Z',
              23.422588207692307,
              -75.48632665384615,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1745251200000',
              '2025-04-21T16:45:00Z',
              23.4283675,
              -75.5090007,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1745251200000',
              '2025-04-21T16:00:00Z',
              23.421883349999998,
              -75.42706516666667,
              NULL,
              NULL,
              NULL
            );
          
DELETE FROM passage_locations WHERE passage_id = 'passage_1745251200000';

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1745251200000',
              '2025-04-21T16:00:00Z',
              23.422189680000002,
              -75.43978571,
              'Exuma',
              'Exuma',
              NULL,
              'The Bahamas',
              'BS',
              'Exuma, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1745251200000',
              '2025-04-21T16:30:00Z',
              23.422588207692307,
              -75.48632665384615,
              'Exuma',
              'Exuma',
              NULL,
              'The Bahamas',
              'BS',
              'Exuma, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1745251200000',
              '2025-04-21T16:45:00Z',
              23.4283675,
              -75.5090007,
              'Exuma',
              'Exuma',
              NULL,
              'The Bahamas',
              'BS',
              'Exuma, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1745251200000',
              '2025-04-21T17:00:00Z',
              23.43588,
              -75.5302049,
              'Exuma',
              'Exuma',
              NULL,
              'The Bahamas',
              'BS',
              'Exuma, The Bahamas',
              '[]'
            );
          

        INSERT OR REPLACE INTO passages (
          id, start_time, end_time, duration, avg_speed, max_speed, distance,
          start_lat, start_lon, end_lat, end_lon, description, name, route,
          export_timestamp, filename, query_metadata, encounters_filename, updated_at
        ) VALUES (
          'passage_1745755200000',
          '2025-04-27T12:00:00Z',
          '2025-04-27T19:00:00Z',
          7,
          2.838229320185371,
          3.3130911750365515,
          32.32685835715056,
          23.786098576541487,
          -75.39528843905038,
          24.319661652769053,
          -75.47428914754447,
          'Passage from 2025-04-27T12:00:00.000Z to 2025-04-27T19:00:00.000Z',
          'Passage passage_1745755200000',
          '23.79, -75.40 → 24.32, -75.47',
          '2025-08-15T18:56:05.768Z',
          'passage_2025-04-27_passage_1745755200000.json',
          NULL,
          NULL,
          unixepoch()
        );
      
DELETE FROM passage_positions WHERE passage_id = 'passage_1745755200000';

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1745755200000',
              '2025-04-27T15:15:00Z',
              24.254369909090908,
              -75.52492699999999,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1745755200000',
              '2025-04-27T15:15:00Z',
              24.240986579999994,
              -75.52961169999999,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1745755200000',
              '2025-04-27T15:30:00Z',
              24.22135147169812,
              -75.53752954716978,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1745755200000',
              '2025-04-27T15:30:00Z',
              24.202459886666663,
              -75.54551320666666,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1745755200000',
              '2025-04-27T15:45:00Z',
              24.17853007831325,
              -75.55421764216864,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1745755200000',
              '2025-04-27T16:00:00Z',
              24.144895284000008,
              -75.54867660133333,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1745755200000',
              '2025-04-27T16:15:00Z',
              24.123028041176468,
              -75.53093662941174,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1745755200000',
              '2025-04-27T17:00:00Z',
              24.074150768571435,
              -75.42131363142857,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1745755200000',
              '2025-04-27T17:15:00Z',
              24.072781185714287,
              -75.39095248571428,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1745755200000',
              '2025-04-27T16:15:00Z',
              24.104264117857145,
              -75.51464379642859,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1745755200000',
              '2025-04-27T16:30:00Z',
              24.084494034567907,
              -75.49650225432097,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1745755200000',
              '2025-04-27T16:45:00Z',
              24.077046232653064,
              -75.46149697551023,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1745755200000',
              '2025-04-27T17:00:00Z',
              24.075454764285716,
              -75.4391369,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1745755200000',
              '2025-04-27T16:15:00Z',
              24.115503200000003,
              -75.52425820833332,
              NULL,
              NULL,
              NULL
            );
          
DELETE FROM passage_locations WHERE passage_id = 'passage_1745755200000';

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1745755200000',
              '2025-04-27T15:15:00Z',
              24.254369909090908,
              -75.52492699999999,
              'Cat Island',
              'Cat Island',
              NULL,
              'The Bahamas',
              'BS',
              'Cat Island, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1745755200000',
              '2025-04-27T15:30:00Z',
              24.22135147169812,
              -75.53752954716978,
              'Cat Island',
              'Cat Island',
              NULL,
              'The Bahamas',
              'BS',
              'Cat Island, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1745755200000',
              '2025-04-27T16:00:00Z',
              24.144895284000008,
              -75.54867660133333,
              'Cat Island',
              'Cat Island',
              NULL,
              'The Bahamas',
              'BS',
              'Cat Island, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1745755200000',
              '2025-04-27T16:30:00Z',
              24.084494034567907,
              -75.49650225432097,
              'Cat Island',
              'Cat Island',
              NULL,
              'The Bahamas',
              'BS',
              'Cat Island, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1745755200000',
              '2025-04-27T17:00:00Z',
              24.074150768571435,
              -75.42131363142857,
              'Cat Island',
              'Cat Island',
              NULL,
              'The Bahamas',
              'BS',
              'Cat Island, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1745755200000',
              '2025-04-27T17:15:00Z',
              24.072781185714287,
              -75.39095248571428,
              'Cat Island',
              'Cat Island',
              NULL,
              'The Bahamas',
              'BS',
              'Cat Island, The Bahamas',
              '[]'
            );
          

        INSERT OR REPLACE INTO passages (
          id, start_time, end_time, duration, avg_speed, max_speed, distance,
          start_lat, start_lon, end_lat, end_lon, description, name, route,
          export_timestamp, filename, query_metadata, encounters_filename, updated_at
        ) VALUES (
          'passage_1746183600000',
          '2025-05-02T11:00:00Z',
          '2025-05-02T18:00:00Z',
          7,
          2.673185356535485,
          3.327287294925605,
          33.830014651246046,
          24.318681626141075,
          -75.52262225684647,
          24.199604551956302,
          -76.12669165632406,
          'Passage from 2025-05-02T11:00:00.000Z to 2025-05-02T18:00:00.000Z',
          'Passage passage_1746183600000',
          '24.32, -75.52 → 24.20, -76.13',
          '2025-08-15T18:56:05.769Z',
          'passage_2025-05-02_passage_1746183600000.json',
          NULL,
          NULL,
          unixepoch()
        );
      
DELETE FROM passage_positions WHERE passage_id = 'passage_1746183600000';

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1746183600000',
              '2025-05-02T12:30:00Z',
              24.4007965,
              -75.08514602999999,
              NULL,
              NULL,
              NULL
            );
          
DELETE FROM passage_locations WHERE passage_id = 'passage_1746183600000';

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1746183600000',
              '2025-05-02T12:30:00Z',
              24.4007965,
              -75.08514602999999,
              'The Bahamas',
              NULL,
              NULL,
              'The Bahamas',
              'BS',
              'The Bahamas',
              '[]'
            );
          

        INSERT OR REPLACE INTO passages (
          id, start_time, end_time, duration, avg_speed, max_speed, distance,
          start_lat, start_lon, end_lat, end_lon, description, name, route,
          export_timestamp, filename, query_metadata, encounters_filename, updated_at
        ) VALUES (
          'passage_1746626400000',
          '2025-05-07T14:00:00Z',
          '2025-05-07T16:00:00Z',
          2,
          2.3735337494805706,
          2.9368144690781275,
          5.377205399085716,
          24.305332978620676,
          -76.61950653586209,
          24.393793863969897,
          -76.63485821222953,
          'Passage from 2025-05-07T14:00:00.000Z to 2025-05-07T16:00:00.000Z',
          'Passage passage_1746626400000',
          '24.31, -76.62 → 24.39, -76.63',
          '2025-08-15T18:56:05.769Z',
          'passage_2025-05-07_passage_1746626400000.json',
          NULL,
          NULL,
          unixepoch()
        );
      
DELETE FROM passage_positions WHERE passage_id = 'passage_1746626400000';

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1746626400000',
              '2025-05-07T15:00:00Z',
              24.5405725,
              -76.80064485,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1746626400000',
              '2025-05-07T15:15:00Z',
              24.532734659999996,
              -76.80151154,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1746626400000',
              '2025-05-07T15:30:00Z',
              24.524929733333334,
              -76.79720318333334,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1746626400000',
              '2025-05-07T16:00:00Z',
              24.523695,
              -76.7962899,
              NULL,
              NULL,
              NULL
            );
          
DELETE FROM passage_locations WHERE passage_id = 'passage_1746626400000';

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1746626400000',
              '2025-05-07T15:00:00Z',
              24.5405725,
              -76.80064485,
              'Exuma',
              'Exuma',
              NULL,
              'The Bahamas',
              'BS',
              'Exuma, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1746626400000',
              '2025-05-07T15:15:00Z',
              24.532734659999996,
              -76.80151154,
              'Exuma',
              'Exuma',
              NULL,
              'The Bahamas',
              'BS',
              'Exuma, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1746626400000',
              '2025-05-07T16:00:00Z',
              24.523695,
              -76.7962899,
              'Exuma',
              'Exuma',
              NULL,
              'The Bahamas',
              'BS',
              'Exuma, The Bahamas',
              '[]'
            );
          

        INSERT OR REPLACE INTO passages (
          id, start_time, end_time, duration, avg_speed, max_speed, distance,
          start_lat, start_lon, end_lat, end_lon, description, name, route,
          export_timestamp, filename, query_metadata, encounters_filename, updated_at
        ) VALUES (
          'passage_1746720000000',
          '2025-05-08T16:00:00Z',
          '2025-05-08T22:00:00Z',
          6,
          3.2880315033674603,
          4.007624039133591,
          33.683574154821216,
          24.452655296047375,
          -76.5841361700263,
          24.863287519722604,
          -76.16352662380625,
          'Passage from 2025-05-08T16:00:00.000Z to 2025-05-08T22:00:00.000Z',
          'Passage passage_1746720000000',
          '24.45, -76.58 → 24.86, -76.16',
          '2025-08-15T18:56:05.769Z',
          'passage_2025-05-08_passage_1746720000000.json',
          NULL,
          NULL,
          unixepoch()
        );
      
DELETE FROM passage_positions WHERE passage_id = 'passage_1746720000000';

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1746720000000',
              '2025-05-08T16:15:00Z',
              24.414732158823533,
              -76.75704545882354,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1746720000000',
              '2025-05-08T16:00:00Z',
              24.409425725000002,
              -76.76817007500001,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1746720000000',
              '2025-05-08T16:15:00Z',
              24.41022875,
              -76.7546600875,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1746720000000',
              '2025-05-08T16:30:00Z',
              24.398757818750003,
              -76.75362133124999,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1746720000000',
              '2025-05-08T16:45:00Z',
              24.388973866666664,
              -76.7515982,
              NULL,
              NULL,
              NULL
            );
          
DELETE FROM passage_locations WHERE passage_id = 'passage_1746720000000';

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1746720000000',
              '2025-05-08T16:00:00Z',
              24.409425725000002,
              -76.76817007500001,
              'Exuma',
              'Exuma',
              NULL,
              'The Bahamas',
              'BS',
              'Exuma, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1746720000000',
              '2025-05-08T16:30:00Z',
              24.398757818750003,
              -76.75362133124999,
              'Exuma',
              'Exuma',
              NULL,
              'The Bahamas',
              'BS',
              'Exuma, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1746720000000',
              '2025-05-08T16:45:00Z',
              24.388973866666664,
              -76.7515982,
              'Exuma',
              'Exuma',
              NULL,
              'The Bahamas',
              'BS',
              'Exuma, The Bahamas',
              '[]'
            );
          

        INSERT OR REPLACE INTO passages (
          id, start_time, end_time, duration, avg_speed, max_speed, distance,
          start_lat, start_lon, end_lat, end_lon, description, name, route,
          export_timestamp, filename, query_metadata, encounters_filename, updated_at
        ) VALUES (
          'passage_1746792000000',
          '2025-05-09T12:00:00Z',
          '2025-05-09T21:00:00Z',
          9,
          3.0823652414892617,
          3.7464728148658613,
          47.651246821738646,
          24.896108086022288,
          -76.23651334758371,
          25.541726576527637,
          -76.7467335474663,
          'Passage from 2025-05-09T12:00:00.000Z to 2025-05-09T21:00:00.000Z',
          'Passage passage_1746792000000',
          '24.90, -76.24 → 25.54, -76.75',
          '2025-08-15T18:56:05.770Z',
          'passage_2025-05-09_passage_1746792000000.json',
          NULL,
          NULL,
          unixepoch()
        );
      
DELETE FROM passage_positions WHERE passage_id = 'passage_1746792000000';

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1746792000000',
              '2025-05-09T18:30:00Z',
              25.446603323076925,
              -76.8425032076923,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1746792000000',
              '2025-05-09T18:45:00Z',
              25.45131536086956,
              -76.84843131739127,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1746792000000',
              '2025-05-09T19:00:00Z',
              25.45875362608696,
              -76.85629421739128,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1746792000000',
              '2025-05-09T19:15:00Z',
              25.46636375,
              -76.86425007916667,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1746792000000',
              '2025-05-09T19:30:00Z',
              25.47380206666666,
              -76.87161073333334,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1746792000000',
              '2025-05-09T19:45:00Z',
              25.482739560869557,
              -76.88091899565218,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1746792000000',
              '2025-05-09T20:00:00Z',
              25.49162091363637,
              -76.88870736363636,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1746792000000',
              '2025-05-09T20:15:00Z',
              25.493164575,
              -76.8884711,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1746792000000',
              '2025-05-09T20:30:00Z',
              25.493184175,
              -76.888511125,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1746792000000',
              '2025-05-09T20:45:00Z',
              25.493198725000003,
              -76.888562375,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1746792000000',
              '2025-05-09T21:00:00Z',
              25.493205,
              -76.888558225,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1746792000000',
              '2025-05-09T17:00:00Z',
              25.410915,
              -76.7931882,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1746792000000',
              '2025-05-09T17:15:00Z',
              25.407786792307693,
              -76.79811410769231,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1746792000000',
              '2025-05-09T17:30:00Z',
              25.412693877777777,
              -76.80936931111113,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1746792000000',
              '2025-05-09T17:45:00Z',
              25.420258414285712,
              -76.82016716666666,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1746792000000',
              '2025-05-09T18:00:00Z',
              25.42621738571429,
              -76.82498058571427,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1746792000000',
              '2025-05-09T18:00:00Z',
              25.430643986666666,
              -76.82813665333335,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1746792000000',
              '2025-05-09T18:15:00Z',
              25.437641326666668,
              -76.83339341333333,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1746792000000',
              '2025-05-09T18:30:00Z',
              25.44293805,
              -76.83855166666666,
              NULL,
              NULL,
              NULL
            );
          
DELETE FROM passage_locations WHERE passage_id = 'passage_1746792000000';

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1746792000000',
              '2025-05-09T17:00:00Z',
              25.410915,
              -76.7931882,
              'North Eleuthera',
              'North Eleuthera',
              NULL,
              'The Bahamas',
              'BS',
              'North Eleuthera, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1746792000000',
              '2025-05-09T17:30:00Z',
              25.412693877777777,
              -76.80936931111113,
              'North Eleuthera',
              'North Eleuthera',
              NULL,
              'The Bahamas',
              'BS',
              'North Eleuthera, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1746792000000',
              '2025-05-09T18:00:00Z',
              25.42621738571429,
              -76.82498058571427,
              'North Eleuthera',
              'North Eleuthera',
              NULL,
              'The Bahamas',
              'BS',
              'North Eleuthera, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1746792000000',
              '2025-05-09T18:30:00Z',
              25.446603323076925,
              -76.8425032076923,
              'North Eleuthera',
              'North Eleuthera',
              NULL,
              'The Bahamas',
              'BS',
              'North Eleuthera, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1746792000000',
              '2025-05-09T19:00:00Z',
              25.45875362608696,
              -76.85629421739128,
              'Spanish Wells',
              'Spanish Wells',
              NULL,
              'The Bahamas',
              'BS',
              'Spanish Wells, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1746792000000',
              '2025-05-09T19:30:00Z',
              25.47380206666666,
              -76.87161073333334,
              'Spanish Wells',
              'Spanish Wells',
              NULL,
              'The Bahamas',
              'BS',
              'Spanish Wells, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1746792000000',
              '2025-05-09T20:00:00Z',
              25.49162091363637,
              -76.88870736363636,
              'Spanish Wells',
              'Spanish Wells',
              NULL,
              'The Bahamas',
              'BS',
              'Spanish Wells, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1746792000000',
              '2025-05-09T20:30:00Z',
              25.493184175,
              -76.888511125,
              'Spanish Wells',
              'Spanish Wells',
              NULL,
              'The Bahamas',
              'BS',
              'Spanish Wells, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1746792000000',
              '2025-05-09T21:00:00Z',
              25.493205,
              -76.888558225,
              'Spanish Wells',
              'Spanish Wells',
              NULL,
              'The Bahamas',
              'BS',
              'Spanish Wells, The Bahamas',
              '[]'
            );
          

        INSERT OR REPLACE INTO passages (
          id, start_time, end_time, duration, avg_speed, max_speed, distance,
          start_lat, start_lon, end_lat, end_lon, description, name, route,
          export_timestamp, filename, query_metadata, encounters_filename, updated_at
        ) VALUES (
          'passage_1747584000000',
          '2025-05-18T16:00:00Z',
          '2025-05-18T22:00:00Z',
          6,
          3.441882143073419,
          3.8915771467669145,
          35.51735805234898,
          25.4096816676617,
          -76.85938203255142,
          24.818332106515363,
          -76.84207956830163,
          'Passage from 2025-05-18T16:00:00.000Z to 2025-05-18T22:00:00.000Z',
          'Passage passage_1747584000000',
          '25.41, -76.86 → 24.82, -76.84',
          '2025-08-15T18:56:05.770Z',
          'passage_2025-05-18_passage_1747584000000.json',
          NULL,
          NULL,
          unixepoch()
        );
      
DELETE FROM passage_positions WHERE passage_id = 'passage_1747584000000';

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1747584000000',
              '2025-05-18T16:45:00Z',
              25.391875555555558,
              -76.7371056,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1747584000000',
              '2025-05-18T17:00:00Z',
              25.391225147619046,
              -76.7460501952381,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1747584000000',
              '2025-05-18T17:15:00Z',
              25.391201886956516,
              -76.75675189565217,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1747584000000',
              '2025-05-18T17:30:00Z',
              25.395148750000004,
              -76.7695007,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1747584000000',
              '2025-05-18T17:45:00Z',
              25.401031185714285,
              -76.78306535714286,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1747584000000',
              '2025-05-18T18:00:00Z',
              25.407003781818176,
              -76.79591275454545,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1747584000000',
              '2025-05-18T18:15:00Z',
              25.4159517,
              -76.7976665,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1747584000000',
              '2025-05-18T16:00:00Z',
              25.40342974210526,
              -76.67853926315789,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1747584000000',
              '2025-05-18T16:15:00Z',
              25.39903159545455,
              -76.69471237272727,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1747584000000',
              '2025-05-18T16:30:00Z',
              25.395125445454543,
              -76.71291721363637,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1747584000000',
              '2025-05-18T16:45:00Z',
              25.393039836363638,
              -76.72686151818182,
              NULL,
              NULL,
              NULL
            );
          
DELETE FROM passage_locations WHERE passage_id = 'passage_1747584000000';

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1747584000000',
              '2025-05-18T16:00:00Z',
              25.40342974210526,
              -76.67853926315789,
              'North Eleuthera',
              'North Eleuthera',
              NULL,
              'The Bahamas',
              'BS',
              'North Eleuthera, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1747584000000',
              '2025-05-18T16:30:00Z',
              25.395125445454543,
              -76.71291721363637,
              'North Eleuthera',
              'North Eleuthera',
              NULL,
              'The Bahamas',
              'BS',
              'North Eleuthera, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1747584000000',
              '2025-05-18T17:00:00Z',
              25.391225147619046,
              -76.7460501952381,
              'North Eleuthera',
              'North Eleuthera',
              NULL,
              'The Bahamas',
              'BS',
              'North Eleuthera, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1747584000000',
              '2025-05-18T17:30:00Z',
              25.395148750000004,
              -76.7695007,
              'North Eleuthera',
              'North Eleuthera',
              NULL,
              'The Bahamas',
              'BS',
              'North Eleuthera, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1747584000000',
              '2025-05-18T18:00:00Z',
              25.407003781818176,
              -76.79591275454545,
              'North Eleuthera',
              'North Eleuthera',
              NULL,
              'The Bahamas',
              'BS',
              'North Eleuthera, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1747584000000',
              '2025-05-18T18:15:00Z',
              25.4159517,
              -76.7976665,
              'North Eleuthera',
              'North Eleuthera',
              NULL,
              'The Bahamas',
              'BS',
              'North Eleuthera, The Bahamas',
              '[]'
            );
          

        INSERT OR REPLACE INTO passages (
          id, start_time, end_time, duration, avg_speed, max_speed, distance,
          start_lat, start_lon, end_lat, end_lon, description, name, route,
          export_timestamp, filename, query_metadata, encounters_filename, updated_at
        ) VALUES (
          'passage_1747674000000',
          '2025-05-19T17:00:00Z',
          '2025-05-19T19:00:00Z',
          2,
          2.4839279302538766,
          3.6750890756303254,
          9.835106134554792,
          24.76069418635407,
          -76.85969262155349,
          24.600666221031727,
          -76.8211879969577,
          'Passage from 2025-05-19T17:00:00.000Z to 2025-05-19T19:00:00.000Z',
          'Passage passage_1747674000000',
          '24.76, -76.86 → 24.60, -76.82',
          '2025-08-15T18:56:05.770Z',
          'passage_2025-05-19_passage_1747674000000.json',
          NULL,
          NULL,
          unixepoch()
        );
      
DELETE FROM passage_locations WHERE passage_id = 'passage_1747674000000';

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1747674000000',
              '2025-05-19T17:00:00Z',
              24.76069418635407,
              -76.85969262155349,
              'Exuma',
              'Exuma',
              NULL,
              'The Bahamas',
              'BS',
              'Exuma, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1747674000000',
              '2025-05-19T19:00:00Z',
              24.600666221031727,
              -76.8211879969577,
              'Exuma',
              'Exuma',
              NULL,
              'The Bahamas',
              'BS',
              'Exuma, The Bahamas',
              '[]'
            );
          

        INSERT OR REPLACE INTO passages (
          id, start_time, end_time, duration, avg_speed, max_speed, distance,
          start_lat, start_lon, end_lat, end_lon, description, name, route,
          export_timestamp, filename, query_metadata, encounters_filename, updated_at
        ) VALUES (
          'passage_1747846800000',
          '2025-05-21T17:00:00Z',
          '2025-05-21T18:00:00Z',
          1,
          1.474789719386485,
          1.7525742574258099,
          2.062955380673469,
          24.561067736842105,
          -76.83005854093567,
          24.547013223766672,
          -76.79558787451401,
          'Passage from 2025-05-21T17:00:00.000Z to 2025-05-21T18:00:00.000Z',
          'Passage passage_1747846800000',
          '24.56, -76.83 → 24.55, -76.80',
          '2025-08-15T18:56:05.771Z',
          'passage_2025-05-21_passage_1747846800000.json',
          NULL,
          NULL,
          unixepoch()
        );
      
DELETE FROM passage_positions WHERE passage_id = 'passage_1747846800000';

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1747846800000',
              '2025-05-21T17:00:00Z',
              24.553240499999998,
              -76.82685038000001,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1747846800000',
              '2025-05-21T17:00:00Z',
              24.551617300000004,
              -76.82302329999999,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1747846800000',
              '2025-05-21T17:15:00Z',
              24.576761169999997,
              -76.81911011000001,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1747846800000',
              '2025-05-21T17:30:00Z',
              24.59452689523809,
              -76.80613629047619,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1747846800000',
              '2025-05-21T17:45:00Z',
              24.6005160375,
              -76.80138758749999,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1747846800000',
              '2025-05-21T18:00:00Z',
              24.6007675,
              -76.8014057,
              NULL,
              NULL,
              NULL
            );
          
DELETE FROM passage_locations WHERE passage_id = 'passage_1747846800000';

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1747846800000',
              '2025-05-21T17:00:00Z',
              24.553240499999998,
              -76.82685038000001,
              'Exuma',
              'Exuma',
              NULL,
              'The Bahamas',
              'BS',
              'Exuma, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1747846800000',
              '2025-05-21T17:30:00Z',
              24.59452689523809,
              -76.80613629047619,
              'Exuma',
              'Exuma',
              NULL,
              'The Bahamas',
              'BS',
              'Exuma, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1747846800000',
              '2025-05-21T18:00:00Z',
              24.6007675,
              -76.8014057,
              'Exuma',
              'Exuma',
              NULL,
              'The Bahamas',
              'BS',
              'Exuma, The Bahamas',
              '[]'
            );
          

        INSERT OR REPLACE INTO passages (
          id, start_time, end_time, duration, avg_speed, max_speed, distance,
          start_lat, start_lon, end_lat, end_lon, description, name, route,
          export_timestamp, filename, query_metadata, encounters_filename, updated_at
        ) VALUES (
          'passage_1747918800000',
          '2025-05-22T13:00:00Z',
          '2025-05-22T17:00:00Z',
          4,
          3.1905458969409914,
          3.751008801624879,
          24.56069005148332,
          24.520128469977415,
          -76.81984061196387,
          24.20907880037736,
          -76.52818546716985,
          'Passage from 2025-05-22T13:00:00.000Z to 2025-05-22T17:00:00.000Z',
          'Passage passage_1747918800000',
          '24.52, -76.82 → 24.21, -76.53',
          '2025-08-15T18:56:05.771Z',
          'passage_2025-05-22_passage_1747918800000.json',
          NULL,
          NULL,
          unixepoch()
        );
      
DELETE FROM passage_positions WHERE passage_id = 'passage_1747918800000';

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1747918800000',
              '2025-05-22T13:00:00Z',
              24.600902525000002,
              -76.8015778,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1747918800000',
              '2025-05-22T13:15:00Z',
              24.600907499999998,
              -76.80154985,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1747918800000',
              '2025-05-22T13:30:00Z',
              24.60090085,
              -76.801526925,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1747918800000',
              '2025-05-22T13:45:00Z',
              24.600892475,
              -76.80150069999999,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1747918800000',
              '2025-05-22T14:00:00Z',
              24.6009172,
              -76.80153986666667,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1747918800000',
              '2025-05-22T14:15:00Z',
              24.600904999999997,
              -76.80151405000001,
              NULL,
              NULL,
              NULL
            );
          
DELETE FROM passage_locations WHERE passage_id = 'passage_1747918800000';

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1747918800000',
              '2025-05-22T13:00:00Z',
              24.600902525000002,
              -76.8015778,
              'Exuma',
              'Exuma',
              NULL,
              'The Bahamas',
              'BS',
              'Exuma, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1747918800000',
              '2025-05-22T13:30:00Z',
              24.60090085,
              -76.801526925,
              'Exuma',
              'Exuma',
              NULL,
              'The Bahamas',
              'BS',
              'Exuma, The Bahamas',
              '[]'
            );
          

        INSERT OR REPLACE INTO passages (
          id, start_time, end_time, duration, avg_speed, max_speed, distance,
          start_lat, start_lon, end_lat, end_lon, description, name, route,
          export_timestamp, filename, query_metadata, encounters_filename, updated_at
        ) VALUES (
          'passage_1748091600000',
          '2025-05-24T13:00:00Z',
          '2025-05-24T21:00:00Z',
          8,
          3.356241000876136,
          3.6222593718338905,
          47.58476745512997,
          24.09038868077999,
          -76.46518438681511,
          23.568277496185253,
          -75.81335258351501,
          'Passage from 2025-05-24T13:00:00.000Z to 2025-05-24T21:00:00.000Z',
          'Passage passage_1748091600000',
          '24.09, -76.47 → 23.57, -75.81',
          '2025-08-15T18:56:05.771Z',
          'passage_2025-05-24_passage_1748091600000.json',
          NULL,
          NULL,
          unixepoch()
        );
      
DELETE FROM passage_positions WHERE passage_id = 'passage_1748091600000';

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1748091600000',
              '2025-05-24T19:45:00Z',
              23.508064575,
              -75.759800275,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1748091600000',
              '2025-05-24T20:00:00Z',
              23.508078750000003,
              -75.75981155000001,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1748091600000',
              '2025-05-24T20:15:00Z',
              23.50809335,
              -75.75982195,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1748091600000',
              '2025-05-24T20:30:00Z',
              23.5080971,
              -75.75981362499999,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1748091600000',
              '2025-05-24T20:45:00Z',
              23.508102233333332,
              -75.75980596666666,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1748091600000',
              '2025-05-24T21:00:00Z',
              23.50810663333333,
              -75.75980876666667,
              NULL,
              NULL,
              NULL
            );
          
DELETE FROM passage_locations WHERE passage_id = 'passage_1748091600000';

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1748091600000',
              '2025-05-24T19:45:00Z',
              23.508064575,
              -75.759800275,
              'Exuma',
              'Exuma',
              NULL,
              'The Bahamas',
              'BS',
              'Exuma, The Bahamas',
              '[]'
            );
          

        INSERT OR REPLACE INTO passages (
          id, start_time, end_time, duration, avg_speed, max_speed, distance,
          start_lat, start_lon, end_lat, end_lon, description, name, route,
          export_timestamp, filename, query_metadata, encounters_filename, updated_at
        ) VALUES (
          'passage_1750701600000',
          '2025-06-23T18:00:00Z',
          '2025-06-24T00:00:00Z',
          6,
          3.0911530300398593,
          3.511557332364229,
          26.39827384835934,
          23.490215041623614,
          -75.68706615726931,
          23.050789865040176,
          -75.70318966595876,
          'Passage from 2025-06-23T18:00:00.000Z to 2025-06-24T00:00:00.000Z',
          'Passage passage_1750701600000',
          '23.49, -75.69 → 23.05, -75.70',
          '2025-08-15T18:56:05.772Z',
          'passage_2025-06-23_passage_1750701600000.json',
          NULL,
          NULL,
          unixepoch()
        );
      
DELETE FROM passage_positions WHERE passage_id = 'passage_1750701600000';

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1750701600000',
              '2025-06-23T18:00:00Z',
              23.5039607,
              -75.76397104285715,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1750701600000',
              '2025-06-23T18:15:00Z',
              23.50395908888889,
              -75.76397523333334,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1750701600000',
              '2025-06-23T18:30:00Z',
              23.503960214285716,
              -75.76397082857144,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1750701600000',
              '2025-06-23T18:45:00Z',
              23.50394335,
              -75.7639711,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1750701600000',
              '2025-06-23T19:00:00Z',
              23.503951133333334,
              -75.76397845,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1750701600000',
              '2025-06-23T19:15:00Z',
              23.503943660000004,
              -75.76398418,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'passage_1750701600000',
              '2025-06-23T19:30:00Z',
              23.50393443333333,
              -75.76398486666666,
              NULL,
              NULL,
              NULL
            );
          
DELETE FROM passage_locations WHERE passage_id = 'passage_1750701600000';

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1750701600000',
              '2025-06-23T18:00:00Z',
              23.5039607,
              -75.76397104285715,
              'Exuma',
              'Exuma',
              NULL,
              'The Bahamas',
              'BS',
              'Exuma, The Bahamas',
              '[]'
            );
          

            INSERT OR REPLACE INTO passage_locations (
              passage_id, time, lat, lon, name, locality, administrative_area,
              country, country_code, formatted_address, points_of_interest
            ) VALUES (
              'passage_1750701600000',
              '2025-06-23T19:30:00Z',
              23.50393443333333,
              -75.76398486666666,
              'Exuma',
              'Exuma',
              NULL,
              'The Bahamas',
              'BS',
              'Exuma, The Bahamas',
              '[]'
            );
          

        INSERT OR REPLACE INTO passages (
          id, start_time, end_time, duration, avg_speed, max_speed, distance,
          start_lat, start_lon, end_lat, end_lon, description, name, route,
          export_timestamp, filename, query_metadata, encounters_filename, updated_at
        ) VALUES (
          'tideye_passage_2025_06_26',
          '2025-06-26T12:30:00Z',
          '2025-07-04T18:00:00Z',
          197.5,
          13.981558673588298,
          23.956378962890998,
          2761.357838033689,
          23.028756917721516,
          -75.71575310443075,
          29.546136172477766,
          -95.02007597858449,
          'Tideye passage from 2025-06-26',
          'Tideye Passage - 2025-06-26',
          '23.03, -75.72 → 29.55, -95.02',
          '2025-12-19T18:39:35.792Z',
          'passage_2025-06-26_tideye_passage_2025_06_26.json',
          NULL,
          'encounters_2025-06-26_tideye_passage_2025_06_26.json',
          unixepoch()
        );
      
DELETE FROM passage_positions WHERE passage_id = 'tideye_passage_2025_06_26';

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T12:30:00Z',
              23.028756917721516,
              -75.71575310443075,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T12:45:00Z',
              23.028765033689503,
              -75.71572322927344,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T13:00:00Z',
              23.02920183875353,
              -75.72129826504309,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T13:15:00Z',
              23.027564639815417,
              -75.72510478325633,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T13:30:00Z',
              23.0221670390855,
              -75.74681594675505,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T13:30:00Z',
              23.01685318367348,
              -75.75970653673467,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T13:45:00Z',
              23.008405759308516,
              -75.77510369527921,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T14:00:00Z',
              22.995087990725796,
              -75.79875673481175,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T14:00:00Z',
              22.986111063187604,
              -75.814422351763,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T14:15:00Z',
              22.97287991192531,
              -75.83726129647994,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T14:30:00Z',
              22.955383815027346,
              -75.86747396140723,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T14:45:00Z',
              22.941885431510116,
              -75.89078574791913,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T14:45:00Z',
              22.9368077075,
              -75.89953379500002,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T14:45:00Z',
              22.93316071774462,
              -75.9058676373134,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T15:00:00Z',
              22.92047716945379,
              -75.92601441159812,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T15:15:00Z',
              22.900946820588224,
              -75.95408815882357,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T15:30:00Z',
              22.88885557049909,
              -75.9810417319073,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T15:30:00Z',
              22.883867787900336,
              -75.99569518896797,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T15:45:00Z',
              22.875840156913444,
              -76.01391746319808,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T16:00:00Z',
              22.86465772545215,
              -76.0427799215673,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T16:15:00Z',
              22.858584980985924,
              -76.05787060985921,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T16:15:00Z',
              22.85124335048701,
              -76.07156450698054,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T16:30:00Z',
              22.84422581780823,
              -76.0847797767123,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T16:30:00Z',
              22.837817307712527,
              -76.09933064890444,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T16:45:00Z',
              22.825417556109798,
              -76.1278814253533,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T17:00:00Z',
              22.812448206518738,
              -76.15742435742015,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T17:15:00Z',
              22.804716579807707,
              -76.17513338910257,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T17:15:00Z',
              22.798835328446003,
              -76.18992331448638,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T17:30:00Z',
              22.788839223144958,
              -76.21654457079657,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T17:45:00Z',
              22.781576996062977,
              -76.23439665787397,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T17:45:00Z',
              22.774265143936745,
              -76.24902373769778,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T18:00:00Z',
              22.762462672210983,
              -76.28040144482748,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T18:00:00Z',
              22.767526359242765,
              -76.26635012115808,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T18:15:00Z',
              22.75522133428182,
              -76.30308163434972,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T18:30:00Z',
              22.74555078199994,
              -76.3298243980666,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T18:45:00Z',
              22.7329085797015,
              -76.36679694119404,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T18:45:00Z',
              22.73727185695658,
              -76.35320262043477,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T19:00:00Z',
              22.728832675796152,
              -76.38405753198866,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T19:15:00Z',
              22.722511564653388,
              -76.4131660611531,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T19:30:00Z',
              22.71536988266844,
              -76.44171274336169,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T19:45:00Z',
              22.707033485922324,
              -76.47958094101939,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T19:45:00Z',
              22.709656610993257,
              -76.46584757531338,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T19:45:00Z',
              22.711941010714288,
              -76.45603165357143,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T20:00:00Z',
              22.702827820112084,
              -76.49777089537494,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T20:15:00Z',
              22.695100498172888,
              -76.52566893387203,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T20:30:00Z',
              22.689206025606232,
              -76.55855512327841,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T20:30:00Z',
              22.69139075434783,
              -76.54448058260863,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T20:45:00Z',
              22.68607298474704,
              -76.58036774526023,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T21:00:00Z',
              22.683087208479744,
              -76.60708295859423,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T21:15:00Z',
              22.675414510365847,
              -76.64295591097554,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T21:15:00Z',
              22.67831034451498,
              -76.63017784161367,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T21:30:00Z',
              22.67087603318809,
              -76.65823298286135,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T21:45:00Z',
              22.661870015702515,
              -76.68534870633599,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T22:00:00Z',
              22.652282606978414,
              -76.70994804919735,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T22:15:00Z',
              22.63433203028172,
              -76.74071670305163,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T22:15:00Z',
              22.642964673161224,
              -76.72769974077423,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T22:15:00Z',
              22.637891579861133,
              -76.7356064954861,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T22:30:00Z',
              22.62556758098496,
              -76.75510945020514,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T22:45:00Z',
              22.611904097986596,
              -76.77819472308718,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T23:00:00Z',
              22.59733099177802,
              -76.80079820274051,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T23:15:00Z',
              22.577804814401652,
              -76.82944186977701,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T23:15:00Z',
              22.58510735185553,
              -76.81892107873624,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T23:30:00Z',
              22.568009626545727,
              -76.84322490907262,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-26T23:45:00Z',
              22.56156953578226,
              -76.8646846399321,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T00:00:00Z',
              22.57912301512844,
              -76.88396088924364,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T00:15:00Z',
              22.598917650206893,
              -76.90242695082767,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T00:30:00Z',
              22.619006040429376,
              -76.92583608041171,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T00:30:00Z',
              22.610276869172928,
              -76.91525152581455,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T00:45:00Z',
              22.63590108925169,
              -76.94360848619027,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T01:00:00Z',
              22.66086580235599,
              -76.96707922722516,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T01:00:00Z',
              22.650388252342516,
              -76.95752052584814,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T01:15:00Z',
              22.677664931787593,
              -76.98070995512333,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T01:30:00Z',
              22.698794940417027,
              -76.99733260400944,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T01:45:00Z',
              22.723031140393037,
              -77.01669685938845,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T01:45:00Z',
              22.712634306925217,
              -77.00791914626043,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T02:00:00Z',
              22.741063241184133,
              -77.03097268815868,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T02:15:00Z',
              22.753384585440635,
              -77.04105682643687,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T02:15:00Z',
              22.764103133437885,
              -77.0505259061224,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T02:30:00Z',
              22.78361889502021,
              -77.06762692133245,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T02:45:00Z',
              22.803748300443868,
              -77.08773874692466,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T03:00:00Z',
              22.82638752396195,
              -77.11010495250875,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T03:00:00Z',
              22.816178119047617,
              -77.10016639391536,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T03:15:00Z',
              22.844677705390435,
              -77.1272356209399,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T03:30:00Z',
              22.856004642253513,
              -77.13721155492958,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T03:30:00Z',
              22.86680558895347,
              -77.14578867957857,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T03:45:00Z',
              22.88783215164985,
              -77.16379044417492,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T04:00:00Z',
              22.91011036097728,
              -77.181411577908,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T04:15:00Z',
              22.916311404668292,
              -77.20601461244874,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T04:15:00Z',
              22.92225846626016,
              -77.19230484796746,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T04:30:00Z',
              22.905451490047678,
              -77.23125987389231,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T04:45:00Z',
              22.89364251792515,
              -77.25946242378252,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T05:00:00Z',
              22.885287456081084,
              -77.28019614881771,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T05:00:00Z',
              22.879874951100803,
              -77.29531280173808,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T05:15:00Z',
              22.87416981664512,
              -77.31195057819352,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T05:15:00Z',
              22.869226507072124,
              -77.32698170254598,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T05:30:00Z',
              22.862903752569455,
              -77.34864351368066,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T05:45:00Z',
              22.853780357412777,
              -77.385770231686,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T05:45:00Z',
              22.857071017360113,
              -77.37081693644195,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T06:00:00Z',
              22.848757375573157,
              -77.40706694940722,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T06:15:00Z',
              22.84180722574982,
              -77.43738761075355,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T06:30:00Z',
              22.831381752499997,
              -77.4757984896155,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T06:30:00Z',
              22.835227255969347,
              -77.46064038630887,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T06:45:00Z',
              22.82606435017374,
              -77.49644074968741,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T07:00:00Z',
              22.819103269594564,
              -77.52660590351351,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T07:15:00Z',
              22.811806842340456,
              -77.56786561723409,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T07:15:00Z',
              22.814284141020217,
              -77.55199456248685,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T07:30:00Z',
              22.808967415892315,
              -77.58837976478102,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T07:45:00Z',
              22.804870555063715,
              -77.61922026854455,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T08:00:00Z',
              22.802677109090904,
              -77.63426926363637,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T08:00:00Z',
              22.80154322272203,
              -77.64409239976922,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T08:00:00Z',
              22.799663691585106,
              -77.65948501409008,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T08:15:00Z',
              22.79659985802737,
              -77.67960977249828,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T08:30:00Z',
              22.791564494855525,
              -77.70901665024658,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T08:45:00Z',
              22.784110859498217,
              -77.74809926487451,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T08:45:00Z',
              22.786464885072082,
              -77.73391220025454,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T09:00:00Z',
              22.781880812030035,
              -77.7645226570744,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T09:15:00Z',
              22.776251614051862,
              -77.79118133226457,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T09:30:00Z',
              22.769704052132077,
              -77.81752277132045,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T09:45:00Z',
              22.763561893436965,
              -77.84712244818623,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T09:45:00Z',
              22.766084489491504,
              -77.83388585457628,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T10:00:00Z',
              22.75871257849238,
              -77.8693879900415,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T10:15:00Z',
              22.75382465341616,
              -77.89415371249152,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T10:30:00Z',
              22.742738383040926,
              -77.92968791637423,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T10:30:00Z',
              22.746742792862754,
              -77.91701479607843,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T10:45:00Z',
              22.738258292123803,
              -77.9433648457101,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T11:00:00Z',
              22.731623010620908,
              -77.97055323153599,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T11:00:00Z',
              22.734386224888883,
              -77.95767866444447,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T11:15:00Z',
              22.725711690836167,
              -77.99302707498326,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T11:30:00Z',
              22.720280587949258,
              -78.01220954862569,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T11:30:00Z',
              22.716645909883752,
              -78.02366862441869,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T11:45:00Z',
              22.71047789727935,
              -78.03918264631722,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T12:00:00Z',
              22.702569604116892,
              -78.06076079548478,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T12:15:00Z',
              22.695528798843544,
              -78.08244798020425,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T12:30:00Z',
              22.68808434180546,
              -78.10207465214742,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T12:30:00Z',
              22.68455764794953,
              -78.11336032365931,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T12:45:00Z',
              22.680392730141055,
              -78.12637398968077,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T13:00:00Z',
              22.674612193274246,
              -78.1481246112344,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T13:15:00Z',
              22.669197373853176,
              -78.17118898891411,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T13:30:00Z',
              22.659971867708336,
              -78.20442263402782,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T13:30:00Z',
              22.663726299172055,
              -78.19267922143506,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T13:45:00Z',
              22.654540241154915,
              -78.21862383764615,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T13:45:00Z',
              22.65894014137931,
              -78.2073364137931,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T14:00:00Z',
              22.647231673544198,
              -78.23890461157465,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T14:15:00Z',
              22.63999217596847,
              -78.25724929218072,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T14:30:00Z',
              22.631005531626215,
              -78.27555175044981,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T14:45:00Z',
              22.618106993246755,
              -78.29808738402602,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T14:45:00Z',
              22.623365314882975,
              -78.2890390021739,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T15:00:00Z',
              22.60944303514517,
              -78.31203761101997,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T15:15:00Z',
              22.597468708304028,
              -78.33015095285008,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T15:30:00Z',
              22.59757260723138,
              -78.34732408071639,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T15:45:00Z',
              22.601989352675467,
              -78.36665630006954,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T16:00:00Z',
              22.605868321920678,
              -78.38053198580376,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T16:00:00Z',
              22.60909486569585,
              -78.39109055296647,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T16:15:00Z',
              22.614006983229803,
              -78.40723329406481,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T16:30:00Z',
              22.619495756509696,
              -78.42658093656512,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T16:45:00Z',
              22.625296861500356,
              -78.44625244189665,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T17:00:00Z',
              22.63070870975267,
              -78.46587171639577,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T17:00:00Z',
              22.63312141304348,
              -78.4756044717391,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T17:15:00Z',
              22.635767193987977,
              -78.48691452010708,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T17:30:00Z',
              22.641031440514233,
              -78.50760706546214,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T17:45:00Z',
              22.64589039679613,
              -78.527374182822,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T18:00:00Z',
              22.65087841728221,
              -78.54645754216027,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T18:15:00Z',
              22.654247765442836,
              -78.56090032192245,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T18:15:00Z',
              22.6555946719178,
              -78.56977525325345,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T18:30:00Z',
              22.65760240555163,
              -78.58253599786474,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T18:45:00Z',
              22.6614243475768,
              -78.60100159085326,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T19:00:00Z',
              22.665456006593402,
              -78.61842150913459,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T19:15:00Z',
              22.67035410124483,
              -78.63696398340254,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T19:30:00Z',
              22.676579830597028,
              -78.66141511746268,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T19:30:00Z',
              22.674174960606067,
              -78.65179398260871,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T19:45:00Z',
              22.67937725806002,
              -78.67517206287505,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T20:00:00Z',
              22.68254315241003,
              -78.69514943781392,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T20:15:00Z',
              22.68589890394547,
              -78.71426316901004,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T20:30:00Z',
              22.690222904906726,
              -78.7342278283345,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T20:45:00Z',
              22.69233722416356,
              -78.74591576840147,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T20:45:00Z',
              22.693927955819653,
              -78.75569845565575,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T21:00:00Z',
              22.695876159530354,
              -78.77379620773479,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T21:15:00Z',
              22.697840755294074,
              -78.79486733550173,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T21:30:00Z',
              22.69973268916497,
              -78.81778226059353,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T21:45:00Z',
              22.700577106862728,
              -78.83394420215687,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T21:45:00Z',
              22.70144665513628,
              -78.84637073480076,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T22:00:00Z',
              22.703820024364088,
              -78.86595806927696,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T22:15:00Z',
              22.713955383672133,
              -78.88897536872128,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T22:30:00Z',
              22.72847956017762,
              -78.91061418169416,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T22:45:00Z',
              22.743333791813495,
              -78.93583289896382,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T22:45:00Z',
              22.737901873632783,
              -78.92521304843741,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T23:00:00Z',
              22.75256095720028,
              -78.95324399993325,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T23:15:00Z',
              22.76452530978973,
              -78.97430586555481,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T23:30:00Z',
              22.777043176283993,
              -78.99496013897281,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T23:45:00Z',
              22.793438536027747,
              -79.02262197852185,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-27T23:45:00Z',
              22.786989406179217,
              -79.01172907003094,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T00:00:00Z',
              22.80201678169739,
              -79.0366541372692,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T00:15:00Z',
              22.817840879832982,
              -79.06218204821,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T00:15:00Z',
              22.810942427717396,
              -79.0517635594203,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T00:30:00Z',
              22.829709202828095,
              -79.07900257759238,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T00:45:00Z',
              22.845305436679244,
              -79.09874470241523,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T01:00:00Z',
              22.854282140336128,
              -79.10888933277312,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T01:00:00Z',
              22.862016179608247,
              -79.11821692983101,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T01:15:00Z',
              22.87829697490666,
              -79.13620754047814,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T01:30:00Z',
              22.89503530126783,
              -79.15490703399365,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T01:45:00Z',
              22.918911400478486,
              -79.18276716076545,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T01:45:00Z',
              22.9101518207265,
              -79.17241292735048,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T02:00:00Z',
              22.936664283864122,
              -79.20387099872617,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T02:00:00Z',
              22.927443810237172,
              -79.19291689051195,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T02:15:00Z',
              22.948053746656633,
              -79.21841611457572,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T02:30:00Z',
              22.963385605116976,
              -79.24114574210536,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T02:45:00Z',
              22.978575910350145,
              -79.26325777937741,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T03:00:00Z',
              22.985786352761924,
              -79.29493062742856,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T03:00:00Z',
              22.983160186085843,
              -79.28267885357606,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T03:15:00Z',
              22.989738832666646,
              -79.31154204783319,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T03:30:00Z',
              22.995217868065826,
              -79.33830802049383,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T03:45:00Z',
              23.00134741517637,
              -79.36289230877782,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T04:00:00Z',
              23.00793364498511,
              -79.39146810198616,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T04:00:00Z',
              23.005047542187526,
              -79.37838139010415,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T04:15:00Z',
              23.013928939234027,
              -79.41574018161701,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T04:30:00Z',
              23.022074926422814,
              -79.44144084813006,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T04:45:00Z',
              23.027917941774177,
              -79.46194252774193,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T04:45:00Z',
              23.030122207142853,
              -79.46950463095234,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T04:45:00Z',
              23.032025256813807,
              -79.4753645823416,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T05:00:00Z',
              23.03764312102315,
              -79.4933427235013,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T05:15:00Z',
              23.04504052828113,
              -79.51808052201518,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T05:30:00Z',
              23.054079596261662,
              -79.54196728402712,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T05:45:00Z',
              23.059457182236855,
              -79.55719983947361,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T05:45:00Z',
              23.06401668479266,
              -79.57030122327184,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T06:00:00Z',
              23.072259104213995,
              -79.59369743241503,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T06:15:00Z',
              23.0800198640068,
              -79.61923804889621,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T06:30:00Z',
              23.085653509840075,
              -79.64109803886835,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T06:30:00Z',
              23.08898185384616,
              -79.65463359280393,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T06:45:00Z',
              23.093836491853093,
              -79.67425993969648,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T07:00:00Z',
              23.101166525835318,
              -79.70037972102699,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T07:15:00Z',
              23.10751115890297,
              -79.7268717540083,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T07:15:00Z',
              23.110226553571437,
              -79.740253675,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T07:30:00Z',
              23.112685702773394,
              -79.75402523462746,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T07:45:00Z',
              23.11672458074011,
              -79.78073263793121,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T08:00:00Z',
              23.124831762236603,
              -79.80506225980562,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T08:15:00Z',
              23.131825610702876,
              -79.82326612619796,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T08:15:00Z',
              23.13602936279864,
              -79.83569130699651,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T08:30:00Z',
              23.14178515372646,
              -79.85302508894343,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T08:45:00Z',
              23.152804902267587,
              -79.88489212607715,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T08:45:00Z',
              23.148297669280232,
              -79.87306962146526,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T09:00:00Z',
              23.159082337777726,
              -79.9015771487301,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T09:15:00Z',
              23.164515936982248,
              -79.9163462822485,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T09:15:00Z',
              23.16874841334044,
              -79.92787820469584,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T09:30:00Z',
              23.176758401335366,
              -79.94874021550427,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T09:45:00Z',
              23.18552569856345,
              -79.97244987661611,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T10:00:00Z',
              23.19397713358836,
              -79.99559639495034,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T10:15:00Z',
              23.204823731356605,
              -80.01790264264821,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T10:15:00Z',
              23.199404757926832,
              -80.00744860182925,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T10:30:00Z',
              23.21432855458575,
              -80.03630123084311,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T10:45:00Z',
              23.22340089082773,
              -80.05479135421335,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T11:00:00Z',
              23.233749279336376,
              -80.07405354276021,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T11:15:00Z',
              23.24497213312101,
              -80.10036402452228,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T11:15:00Z',
              23.2412993725212,
              -80.09097568111409,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T11:30:00Z',
              23.248865571875033,
              -80.11296897805398,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T11:45:00Z',
              23.25674358349444,
              -80.13473628394057,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T12:00:00Z',
              23.26608061686643,
              -80.15739631626717,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T12:00:00Z',
              23.26194280425532,
              -80.14689847304969,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T12:15:00Z',
              23.271857291947846,
              -80.17673721664119,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T12:15:00Z',
              23.274934950000002,
              -80.18782861875002,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T12:30:00Z',
              23.277647988573747,
              -80.1984608636723,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T12:45:00Z',
              23.283160547054376,
              -80.22055290287022,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T13:00:00Z',
              23.28934843224829,
              -80.24464931392906,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T13:15:00Z',
              23.29850594578947,
              -80.27866583000004,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T13:15:00Z',
              23.295352715668603,
              -80.26644100418385,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T13:30:00Z',
              23.3022468111842,
              -80.29310862324559,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T13:45:00Z',
              23.30886217785765,
              -80.3190176431342,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T14:00:00Z',
              23.31476528436861,
              -80.3434636313994,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T14:15:00Z',
              23.32104128023403,
              -80.37341538439523,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T14:15:00Z',
              23.318298360695675,
              -80.36089274886962,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T14:30:00Z',
              23.325615098531394,
              -80.39403831727277,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T14:45:00Z',
              23.331038842514925,
              -80.42003035898222,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T15:00:00Z',
              23.336154712365598,
              -80.4431082481569,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T15:00:00Z',
              23.33834676422019,
              -80.4558344055046,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T15:15:00Z',
              23.340778497421198,
              -80.46976008280814,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T15:30:00Z',
              23.34537959501776,
              -80.49449194419925,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T15:45:00Z',
              23.350355048807902,
              -80.52014317005616,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T16:00:00Z',
              23.353364379703716,
              -80.53811753674076,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T16:00:00Z',
              23.355227670945006,
              -80.55014070126938,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T16:15:00Z',
              23.357870249860877,
              -80.57027384638404,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T16:30:00Z',
              23.35221824611193,
              -80.59766799686196,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T16:45:00Z',
              23.346768331490832,
              -80.62193219304837,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T16:45:00Z',
              23.34185077033492,
              -80.63458196698568,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T17:00:00Z',
              23.3366656786189,
              -80.64937098074364,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T17:15:00Z',
              23.327636812416145,
              -80.67435953013423,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T17:30:00Z',
              23.31861046233585,
              -80.69906182107806,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T17:45:00Z',
              23.31233299607481,
              -80.71677108953277,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T17:45:00Z',
              23.307600747762898,
              -80.72953719787483,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T18:00:00Z',
              23.302066743402797,
              -80.74494357893518,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T18:00:00Z',
              23.297958637865694,
              -80.75836036867474,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T18:15:00Z',
              23.298946853129216,
              -80.77775931850351,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T18:30:00Z',
              23.30269998056678,
              -80.81511554473677,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T18:30:00Z',
              23.301144731663115,
              -80.80037236108737,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T18:45:00Z',
              23.303729769741086,
              -80.82965174951458,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T18:45:00Z',
              23.30440136958084,
              -80.83707317461077,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T19:00:00Z',
              23.305059280430406,
              -80.86232256798922,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T19:15:00Z',
              23.306712520338948,
              -80.90314786585965,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T19:15:00Z',
              23.306361478134107,
              -80.8880252594754,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T19:30:00Z',
              23.306051222199304,
              -80.92200164570443,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T19:45:00Z',
              23.304467864265522,
              -80.95118570141224,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T20:00:00Z',
              23.301737384772036,
              -80.97665110164887,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T20:00:00Z',
              23.299930809112738,
              -80.9916454990408,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T20:15:00Z',
              23.29799057108273,
              -81.01022010094165,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T20:30:00Z',
              23.294902706697076,
              -81.03929193654096,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T20:45:00Z',
              23.290486622641495,
              -81.07965786721692,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T20:45:00Z',
              23.29222776620088,
              -81.06466853755452,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T21:00:00Z',
              23.288707951897074,
              -81.09926380475882,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T21:15:00Z',
              23.28508734860261,
              -81.13012198943431,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T21:30:00Z',
              23.281455310928933,
              -81.15494485704906,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T21:30:00Z',
              23.278809814262296,
              -81.16928793836057,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T21:45:00Z',
              23.27492189479298,
              -81.18956428456718,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T22:00:00Z',
              23.26910372746342,
              -81.21925559777493,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T22:15:00Z',
              23.265071168421095,
              -81.24305044339178,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T22:15:00Z',
              23.263098528823505,
              -81.2585826817648,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T22:30:00Z',
              23.260893483221,
              -81.28081932796522,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T22:45:00Z',
              23.2575102974537,
              -81.31264652854921,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T23:00:00Z',
              23.255709947169862,
              -81.3340254898799,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T23:00:00Z',
              23.254324212931056,
              -81.34962361433193,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T23:15:00Z',
              23.251903457464252,
              -81.3752299830267,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T23:30:00Z',
              23.25002156154381,
              -81.4062173460361,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T23:45:00Z',
              23.246999225429544,
              -81.44032433771483,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-28T23:45:00Z',
              23.24887665971224,
              -81.42495000395687,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T00:00:00Z',
              23.24414841085614,
              -81.47087509126207,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T00:00:00Z',
              23.245211534042568,
              -81.45580804255322,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T00:15:00Z',
              23.242381214642432,
              -81.49843258144395,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T00:30:00Z',
              23.239577420810615,
              -81.52840198713936,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T00:30:00Z',
              23.24107039132948,
              -81.5140802404624,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T00:45:00Z',
              23.236570532441462,
              -81.55461825384631,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T01:00:00Z',
              23.233058716443892,
              -81.58240034385022,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T01:15:00Z',
              23.231283216582927,
              -81.59989072814065,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T01:15:00Z',
              23.23654284205079,
              -81.61328750846654,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T01:30:00Z',
              23.243318913692956,
              -81.63659313720606,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T01:45:00Z',
              23.244675379155353,
              -81.66232807030833,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T02:00:00Z',
              23.244945761494883,
              -81.68338503567392,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T02:00:00Z',
              23.24438188882982,
              -81.69658963546087,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T02:15:00Z',
              23.243219123895628,
              -81.71490208400236,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T02:30:00Z',
              23.240232967067424,
              -81.74011279699391,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T02:45:00Z',
              23.237256048410384,
              -81.76541684797677,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T02:45:00Z',
              23.235825525892846,
              -81.77974436160714,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T03:00:00Z',
              23.2348760016118,
              -81.79547608146419,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T03:15:00Z',
              23.235225762958134,
              -81.82479001989509,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T03:30:00Z',
              23.2371028764114,
              -81.85299912111356,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T03:30:00Z',
              23.238025073333333,
              -81.86835120666666,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T03:45:00Z',
              23.239946443384827,
              -81.88582885889859,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T04:00:00Z',
              23.243312385021113,
              -81.9158663721521,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T04:15:00Z',
              23.245448286267596,
              -81.94241539154923,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T04:15:00Z',
              23.24620081721519,
              -81.95753218101258,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T04:30:00Z',
              23.247132189321068,
              -81.97609726868816,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T04:45:00Z',
              23.247937165990898,
              -82.00575480104656,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T05:00:00Z',
              23.247801848872975,
              -82.0307147925205,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T05:00:00Z',
              23.248034593920327,
              -82.04538737274636,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T05:15:00Z',
              23.24781662117647,
              -82.06530157813148,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T05:30:00Z',
              23.247351984900423,
              -82.09607517522312,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T05:45:00Z',
              23.24679614041092,
              -82.12005936726025,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T05:45:00Z',
              23.24696481934705,
              -82.13636119854898,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T06:00:00Z',
              23.24734889419913,
              -82.16090604001322,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T06:15:00Z',
              23.247672417663143,
              -82.19385451161504,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T06:30:00Z',
              23.249577718396935,
              -82.22956039839686,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T06:30:00Z',
              23.248720806369423,
              -82.2128101101911,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T06:45:00Z',
              23.251087479480393,
              -82.26097874816793,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T07:00:00Z',
              23.252069915563496,
              -82.28961858613572,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T07:00:00Z',
              23.25311123333336,
              -82.3061944534945,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T07:15:00Z',
              23.254292389759087,
              -82.32675168982595,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T07:30:00Z',
              23.254560650444905,
              -82.35907077542774,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T07:45:00Z',
              23.25399653800324,
              -82.38213361062807,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T07:45:00Z',
              23.254012835033272,
              -82.39835440709534,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T08:00:00Z',
              23.25450560019935,
              -82.4238977104318,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T08:15:00Z',
              23.254750504397098,
              -82.45577931978683,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T08:30:00Z',
              23.25540907354497,
              -82.47346979947086,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T08:30:00Z',
              23.255016843150692,
              -82.48854915327243,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T08:45:00Z',
              23.255091395034484,
              -82.51742177868964,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T09:00:00Z',
              23.255203924847326,
              -82.54761887447403,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T09:00:00Z',
              23.255693948571444,
              -82.56218490571432,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T09:15:00Z',
              23.256604303180627,
              -82.5767491958651,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T09:30:00Z',
              23.261069623378315,
              -82.60547559817543,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T09:45:00Z',
              23.264648153516493,
              -82.63215382237127,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T10:00:00Z',
              23.261824155555566,
              -82.6468950376543,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T10:00:00Z',
              23.260209982618907,
              -82.65987930615763,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T10:15:00Z',
              23.258765930981166,
              -82.68430802318551,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T10:30:00Z',
              23.256236849103033,
              -82.7109845617939,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T10:45:00Z',
              23.25381254152133,
              -82.72959003581623,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T10:45:00Z',
              23.252522789942827,
              -82.74219016800008,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T11:00:00Z',
              23.248572866377085,
              -82.76305268823522,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T11:15:00Z',
              23.243461131957385,
              -82.78865862410115,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T11:30:00Z',
              23.24029497287228,
              -82.8110463565351,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T11:30:00Z',
              23.23858859615385,
              -82.82228433626373,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T11:45:00Z',
              23.23546605715236,
              -82.83556428542904,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T12:00:00Z',
              23.2299074340108,
              -82.860978148645,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T12:15:00Z',
              23.220623390612264,
              -82.89676414551032,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T12:15:00Z',
              23.224319260272775,
              -82.88300155300004,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T12:30:00Z',
              23.2199384675045,
              -82.9173321340216,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T12:30:00Z',
              23.21916719273178,
              -82.90390482957396,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T12:45:00Z',
              23.214345258327914,
              -82.94121446701763,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T13:00:00Z',
              23.206955187973385,
              -82.96937724352188,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T13:15:00Z',
              23.19648606711407,
              -83.00404656500484,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T13:15:00Z',
              23.20113741587984,
              -82.98864338712445,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T13:30:00Z',
              23.187927144386723,
              -83.02990700778714,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T13:45:00Z',
              23.175345051942983,
              -83.0610046867876,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T14:00:00Z',
              23.16290102216455,
              -83.09330419911055,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T14:00:00Z',
              23.168934827692315,
              -83.07770534923075,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T14:15:00Z',
              23.152163279526082,
              -83.12171734298893,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T14:30:00Z',
              23.137938144178055,
              -83.1603260695206,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T14:30:00Z',
              23.142862900502063,
              -83.14767979983259,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T14:45:00Z',
              23.136858722608668,
              -83.1638089095652,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T14:45:00Z',
              23.133859584549963,
              -83.17841791856833,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T15:00:00Z',
              23.128646711608877,
              -83.2076479864353,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T15:15:00Z',
              23.118591927374297,
              -83.25239953631281,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T15:15:00Z',
              23.12252535565608,
              -83.23639147413292,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T15:30:00Z',
              23.11405202513264,
              -83.26953385755981,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T15:45:00Z',
              23.10653700344117,
              -83.29975649125927,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T16:00:00Z',
              23.101078271004013,
              -83.32509040618463,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T16:00:00Z',
              23.098432633600012,
              -83.33838231999998,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T16:15:00Z',
              23.095755875886535,
              -83.3540278162476,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T16:30:00Z',
              23.091663913979218,
              -83.3797274829067,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T16:45:00Z',
              23.086576554558018,
              -83.40608708814267,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T17:00:00Z',
              23.082512306982,
              -83.43194040352853,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T17:00:00Z',
              23.083395508771932,
              -83.42013568479526,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T17:15:00Z',
              23.07864052564985,
              -83.4540152491108,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T17:30:00Z',
              23.07776418709895,
              -83.47525713395721,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T17:45:00Z',
              23.079093443212738,
              -83.51208397601815,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T17:45:00Z',
              23.078695354819324,
              -83.49756145823295,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T18:00:00Z',
              23.079586091873306,
              -83.53058037568869,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T18:15:00Z',
              23.08037783841728,
              -83.5600101294246,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T18:30:00Z',
              23.081443760996613,
              -83.59905508745703,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T18:30:00Z',
              23.08101339182241,
              -83.58331736553751,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T18:45:00Z',
              23.081944111813783,
              -83.61929706518424,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T19:00:00Z',
              23.082736851674383,
              -83.64911252074857,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T19:15:00Z',
              23.08371350022619,
              -83.68598495169682,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T19:15:00Z',
              23.083306938888864,
              -83.6708247545045,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T19:30:00Z',
              23.08428261807153,
              -83.71038196115983,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T19:45:00Z',
              23.0846031806619,
              -83.74091941823477,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T20:00:00Z',
              23.085497354325035,
              -83.77454874777693,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T20:00:00Z',
              23.084807107485048,
              -83.75914106706584,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T20:15:00Z',
              23.088922992734524,
              -83.8004543276089,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T20:30:00Z',
              23.096163672683563,
              -83.8260389326699,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T20:45:00Z',
              23.10180862804641,
              -83.84289121353964,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T20:45:00Z',
              23.104428781497337,
              -83.85526815026749,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T21:00:00Z',
              23.10180597001352,
              -83.8742899012129,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T21:15:00Z',
              23.100767039385705,
              -83.89743680607506,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T21:30:00Z',
              23.10830524714715,
              -83.9352744843843,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T21:30:00Z',
              23.105464343507556,
              -83.92122218634061,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T21:45:00Z',
              23.111974514429512,
              -83.95353107812083,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T22:00:00Z',
              23.11810454513515,
              -83.98400441060811,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T22:15:00Z',
              23.123023164907657,
              -84.00840770976257,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T22:15:00Z',
              23.126319171485402,
              -84.02486636604765,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T22:30:00Z',
              23.131553000603226,
              -84.05095440194376,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T22:45:00Z',
              23.141697276315785,
              -84.10162394999998,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T22:45:00Z',
              23.138498432837867,
              -84.0856368882434,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T23:00:00Z',
              23.14502872733912,
              -84.11829346602511,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T23:15:00Z',
              23.15137708475273,
              -84.15004736435445,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T23:30:00Z',
              23.15979975833334,
              -84.19214494395419,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T23:30:00Z',
              23.156588029621375,
              -84.17612143118039,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-29T23:45:00Z',
              23.1639806190855,
              -84.21320192001313,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T00:00:00Z',
              23.170121014178598,
              -84.2439452907974,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T00:15:00Z',
              23.176965684227806,
              -84.27847544107345,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T00:15:00Z',
              23.174229867725728,
              -84.26459815234121,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T00:30:00Z',
              23.18112651369042,
              -84.29936726507927,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T00:45:00Z',
              23.184292692363634,
              -84.315285116,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T00:45:00Z',
              23.18698916147674,
              -84.32803851589085,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T01:00:00Z',
              23.192865002037074,
              -84.35868874111121,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T01:00:00Z',
              23.190597054535758,
              -84.34634746328699,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T01:15:00Z',
              23.196116979101372,
              -84.37640890136143,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T01:30:00Z',
              23.201947618193923,
              -84.40422486401052,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T01:45:00Z',
              23.213022055665046,
              -84.4421690268473,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T01:45:00Z',
              23.20889142609485,
              -84.42844107527385,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T02:00:00Z',
              23.218338033535403,
              -84.4599768558249,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T02:15:00Z',
              23.226674239794495,
              -84.48776549589047,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T02:30:00Z',
              23.237970229885036,
              -84.52549362614927,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T02:30:00Z',
              23.2338454521664,
              -84.51183732253027,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T02:45:00Z',
              23.244378277905337,
              -84.54236645108116,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T03:00:00Z',
              23.255433432863835,
              -84.56913292012062,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T03:15:00Z',
              23.271396180120483,
              -84.60735383192775,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T03:15:00Z',
              23.265430753863814,
              -84.59435967016059,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T03:30:00Z',
              23.276531570027416,
              -84.61427383614539,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T03:45:00Z',
              23.285371853217946,
              -84.6295901928719,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T04:00:00Z',
              23.297294699786487,
              -84.65386663864773,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T04:00:00Z',
              23.29086016721312,
              -84.64200795901638,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T04:15:00Z',
              23.310457675017272,
              -84.67685990648707,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T04:30:00Z',
              23.317854709230765,
              -84.68917256307694,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T04:30:00Z',
              23.325763219207822,
              -84.7006832247383,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T04:45:00Z',
              23.342083540118132,
              -84.72204379218643,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T05:00:00Z',
              23.359033337608533,
              -84.7431356346692,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T05:15:00Z',
              23.376612545729646,
              -84.76342581815742,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T05:15:00Z',
              23.384955800000007,
              -84.77369361509434,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T05:30:00Z',
              23.39729228489424,
              -84.78686012205445,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T05:30:00Z',
              23.387996560251068,
              -84.7771737642261,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T05:45:00Z',
              23.413464141759754,
              -84.80318470090779,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T06:00:00Z',
              23.432188420729247,
              -84.82210291836579,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T06:15:00Z',
              23.45261242341726,
              -84.83923830776044,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T06:30:00Z',
              23.480403114179126,
              -84.85991940597017,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T06:30:00Z',
              23.469689634820394,
              -84.85192175451577,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T06:45:00Z',
              23.49671932898305,
              -84.87188904161022,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T06:45:00Z',
              23.48635070038314,
              -84.86463921034479,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T07:00:00Z',
              23.515266880660665,
              -84.8851871287682,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T07:15:00Z',
              23.536019165181095,
              -84.89985830891378,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T07:30:00Z',
              23.554491026276413,
              -84.91451721872043,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T07:45:00Z',
              23.571685680691047,
              -84.92824377486443,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T08:00:00Z',
              23.58552907105263,
              -84.94043995000001,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T08:00:00Z',
              23.590780639928507,
              -84.94416235113236,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T08:00:00Z',
              23.582114723540894,
              -84.93765505603122,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T08:15:00Z',
              23.602745437928636,
              -84.95487766354091,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T08:30:00Z',
              23.616809965356435,
              -84.96822384170561,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T08:45:00Z',
              23.631940764658715,
              -84.98244451050863,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T09:00:00Z',
              23.647678128296704,
              -84.9966599958792,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T09:15:00Z',
              23.663763426662182,
              -85.00946109501345,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T09:30:00Z',
              23.676099951804662,
              -85.01936256486195,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T09:30:00Z',
              23.682345035111123,
              -85.02427728622224,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T09:30:00Z',
              23.685363587457612,
              -85.02641136474581,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T09:45:00Z',
              23.69563119892622,
              -85.03406682073845,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T10:00:00Z',
              23.71477100114452,
              -85.0464632185978,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T10:15:00Z',
              23.73445495637326,
              -85.0594556887709,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T10:30:00Z',
              23.754368158567434,
              -85.07411455554791,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T10:45:00Z',
              23.781683542682906,
              -85.09556341585372,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T10:45:00Z',
              23.772480669603176,
              -85.088296871746,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T11:00:00Z',
              23.795400827241952,
              -85.10982395516073,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T11:00:00Z',
              23.78716366358451,
              -85.10144810593602,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T11:15:00Z',
              23.80791933355524,
              -85.12027595246347,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T11:30:00Z',
              23.826275711081095,
              -85.1330164443242,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T11:45:00Z',
              23.845900246004025,
              -85.14246966715928,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T12:00:00Z',
              23.86445609805474,
              -85.1504511858789,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T12:15:00Z',
              23.884591940513314,
              -85.15849666067817,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T12:15:00Z',
              23.875480503529406,
              -85.15479365617641,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T12:30:00Z',
              23.900056126120468,
              -85.16516037233889,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T12:45:00Z',
              23.91409889894247,
              -85.17563374382021,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T13:00:00Z',
              23.926529123032083,
              -85.18506779482513,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T13:00:00Z',
              23.932939652413797,
              -85.1899313213793,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T13:15:00Z',
              23.939860931069244,
              -85.19510136388706,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T13:30:00Z',
              23.953722809439334,
              -85.2061553241308,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T13:45:00Z',
              23.975976926086958,
              -85.22027158869572,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T13:45:00Z',
              23.967706851793178,
              -85.21576499683063,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T14:00:00Z',
              23.985710051308875,
              -85.22515732153148,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T14:15:00Z',
              24.003061532810325,
              -85.23566189201901,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T14:30:00Z',
              24.013771567525787,
              -85.25619685128872,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T14:45:00Z',
              24.021111393638666,
              -85.28220421857489,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T14:45:00Z',
              24.018423955776875,
              -85.26989938446216,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T15:00:00Z',
              24.026643548145596,
              -85.30364137843405,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T15:15:00Z',
              24.033102077770394,
              -85.32638041226902,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T15:30:00Z',
              24.03990901252698,
              -85.3586486127429,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T15:30:00Z',
              24.037618693917064,
              -85.346123013825,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T15:45:00Z',
              24.043369223240425,
              -85.37352917197866,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T16:00:00Z',
              24.04827233317073,
              -85.39531902083634,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T16:15:00Z',
              24.05219881381448,
              -85.41779285491424,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T16:30:00Z',
              24.058129122358157,
              -85.44477840778656,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T16:30:00Z',
              24.05547544309701,
              -85.4334884796642,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T16:45:00Z',
              24.062217976611784,
              -85.46276133395057,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T17:00:00Z',
              24.06742365851351,
              -85.48376938304041,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T17:15:00Z',
              24.071624849469202,
              -85.50564071238506,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T17:30:00Z',
              24.075619987222243,
              -85.52971544849211,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T17:30:00Z',
              24.073775740540523,
              -85.51827802522526,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T17:45:00Z',
              24.078185993779893,
              -85.54690733983271,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T17:45:00Z',
              24.080760609768188,
              -85.5583103433775,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T18:00:00Z',
              24.084618604630272,
              -85.57460951375246,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T18:15:00Z',
              24.088729993698653,
              -85.59356258557082,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T18:15:00Z',
              24.09144333214287,
              -85.60489195297622,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T18:30:00Z',
              24.094357061644743,
              -85.61835081140299,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T18:45:00Z',
              24.09978089127953,
              -85.63848961093642,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T19:00:00Z',
              24.10536383074757,
              -85.65726248441455,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T19:15:00Z',
              24.11477474201131,
              -85.6772255118421,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T19:15:00Z',
              24.12154962319202,
              -85.68714677730674,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T19:30:00Z',
              24.13028483835245,
              -85.69994745273472,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T19:45:00Z',
              24.143919855936655,
              -85.7199674656993,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T20:00:00Z',
              24.158039947937766,
              -85.74069825415826,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T20:15:00Z',
              24.169960385580637,
              -85.75820607708499,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T20:15:00Z',
              24.17662285566503,
              -85.76800920591133,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T20:30:00Z',
              24.186600110843344,
              -85.78264664064257,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T20:30:00Z',
              24.179086000649345,
              -85.77161059805182,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T20:45:00Z',
              24.199723650609737,
              -85.80194436361771,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T21:00:00Z',
              24.21349688153033,
              -85.82219084604222,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T21:15:00Z',
              24.2321140013289,
              -85.8496270342193,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T21:15:00Z',
              24.225789629392146,
              -85.84029073497088,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T21:30:00Z',
              24.239419544892435,
              -85.86034856142476,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T21:45:00Z',
              24.25357520624563,
              -85.88121398854969,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T22:00:00Z',
              24.267522491126257,
              -85.90176980368598,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T22:15:00Z',
              24.2832385030418,
              -85.92489068212929,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T22:15:00Z',
              24.277127002600015,
              -85.91590216899996,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T22:15:00Z',
              24.28798986347033,
              -85.93187898082196,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T22:30:00Z',
              24.296098988441553,
              -85.94385345259752,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T22:45:00Z',
              24.3103484321309,
              -85.96485826212422,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T23:00:00Z',
              24.324528713859983,
              -85.98578033354116,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T23:15:00Z',
              24.343951896706592,
              -86.01443284071858,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T23:15:00Z',
              24.33697200599311,
              -86.0041347202054,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T23:30:00Z',
              24.352958753486785,
              -86.02772570509094,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-06-30T23:45:00Z',
              24.36902305859268,
              -86.05154158017602,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T00:00:00Z',
              24.379886849090912,
              -86.09438520727274,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T00:00:00Z',
              24.379337312852677,
              -86.0905552191222,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T00:00:00Z',
              24.377330986032565,
              -86.07573436803771,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T00:15:00Z',
              24.38280493157184,
              -86.10889499186997,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T00:30:00Z',
              24.384914728756016,
              -86.13792784670302,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T00:45:00Z',
              24.385327536926646,
              -86.17954393922031,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T00:45:00Z',
              24.38516716902077,
              -86.16423111873836,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T01:00:00Z',
              24.385512421442677,
              -86.19887325413633,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T01:15:00Z',
              24.385813353383966,
              -86.2294790588868,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T01:30:00Z',
              24.386178362995672,
              -86.26591653469163,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T01:30:00Z',
              24.386027150000093,
              -86.25052656128481,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T01:45:00Z',
              24.386419741666625,
              -86.2917513661247,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T02:00:00Z',
              24.386861598979582,
              -86.33865597040817,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T02:00:00Z',
              24.386708532423295,
              -86.32247469556307,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T02:15:00Z',
              24.387009606126504,
              -86.35602982279308,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T02:30:00Z',
              24.387294026808775,
              -86.38872082409561,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T02:45:00Z',
              24.387645200441494,
              -86.4284546343268,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T02:45:00Z',
              24.387490186990675,
              -86.4119001763324,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T03:00:00Z',
              24.38791405787894,
              -86.46078865717173,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T03:00:00Z',
              24.387769842938006,
              -86.44403357777782,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T03:15:00Z',
              24.388224113445318,
              -86.50239100126055,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T03:15:00Z',
              24.38810272166163,
              -86.48594102663026,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T03:30:00Z',
              24.388369993189492,
              -86.52172664012144,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T03:45:00Z',
              24.388639495092047,
              -86.55579803926386,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T04:00:00Z',
              24.388801782649832,
              -86.5765675403786,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T04:00:00Z',
              24.388941036177815,
              -86.5941267383112,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T04:15:00Z',
              24.390083460669477,
              -86.61310714372382,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T04:15:00Z',
              24.395163529855395,
              -86.62999866652866,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T04:30:00Z',
              24.40217398754483,
              -86.65167368191614,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T04:30:00Z',
              24.408613128662378,
              -86.6683427130574,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T04:45:00Z',
              24.417722914645484,
              -86.69174356110004,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T05:00:00Z',
              24.430682085932325,
              -86.72503595414747,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T05:15:00Z',
              24.437073914285715,
              -86.74148547857143,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T05:15:00Z',
              24.443495311251606,
              -86.75801348149125,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T05:30:00Z',
              24.45647358115458,
              -86.79147194226928,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T05:45:00Z',
              24.465665068292694,
              -86.81517378170726,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T05:45:00Z',
              24.472237369815687,
              -86.83247770725828,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T06:00:00Z',
              24.48283197922164,
              -86.85981227866574,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T06:15:00Z',
              24.494602716881253,
              -86.89295211258948,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T06:15:00Z',
              24.490923617689525,
              -86.88062426317694,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T06:15:00Z',
              24.497555914218005,
              -86.90789816208535,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T06:30:00Z',
              24.50205749946381,
              -86.93245531494661,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T06:45:00Z',
              24.508582964794314,
              -86.96657323409806,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T06:45:00Z',
              24.5118474164502,
              -86.98538933290043,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T07:00:00Z',
              24.514892238707514,
              -87.00677376568963,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T07:15:00Z',
              24.52066646188223,
              -87.04439315023691,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T07:15:00Z',
              24.52350481428571,
              -87.06295387142855,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T07:30:00Z',
              24.52636554786543,
              -87.0816242402976,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T07:45:00Z',
              24.531927025327242,
              -87.11806185844259,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T08:00:00Z',
              24.535176218672177,
              -87.1392493941909,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T08:00:00Z',
              24.53797513514775,
              -87.15759866306355,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T08:15:00Z',
              24.543174829518872,
              -87.19170961619004,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T08:30:00Z',
              24.546865388957034,
              -87.21599530040892,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T08:30:00Z',
              24.549704871159594,
              -87.2346906349854,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T08:45:00Z',
              24.554488542263186,
              -87.2662102108385,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T09:00:00Z',
              24.558600815797316,
              -87.29338971445608,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T09:00:00Z',
              24.561470378635395,
              -87.31242313881438,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T09:15:00Z',
              24.56605547286458,
              -87.34272051438883,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T09:30:00Z',
              24.570388276190464,
              -87.37149595034016,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T09:30:00Z',
              24.573293826692677,
              -87.39067565690094,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T09:45:00Z',
              24.5777790255503,
              -87.42045433902591,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T10:00:00Z',
              24.582188496313893,
              -87.44979623436379,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T10:00:00Z',
              24.585056992526145,
              -87.46885511823601,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T10:15:00Z',
              24.589212320733363,
              -87.49644623413346,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T10:30:00Z',
              24.596673222810196,
              -87.54633224671527,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T10:30:00Z',
              24.593843968762634,
              -87.52741103894519,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T10:45:00Z',
              24.598675986775326,
              -87.55976097264492,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T10:45:00Z',
              24.601514132421503,
              -87.57870298145887,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T11:00:00Z',
              24.608256947517713,
              -87.62387483215123,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T11:00:00Z',
              24.605383511132075,
              -87.60467623981131,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T11:15:00Z',
              24.611951624269864,
              -87.64860245542424,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T11:30:00Z',
              24.61698086609879,
              -87.68241984838176,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T11:30:00Z',
              24.61981442319273,
              -87.70162688795176,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T11:45:00Z',
              24.623290217823797,
              -87.72491082189582,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T12:00:00Z',
              24.631338668055584,
              -87.77910477361102,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T12:00:00Z',
              24.628507740559428,
              -87.7600375322458,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T12:15:00Z',
              24.63446267613963,
              -87.8002557918805,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T12:30:00Z',
              24.639942432632314,
              -87.83733267664995,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T12:30:00Z',
              24.642663215277782,
              -87.85585210972224,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T12:45:00Z',
              24.651737185542938,
              -87.87447113730865,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T13:00:00Z',
              24.67367570634602,
              -87.90937362658663,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T13:15:00Z',
              24.694643435479634,
              -87.94248662115628,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T13:15:00Z',
              24.686939172794123,
              -87.93031759448529,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T13:15:00Z',
              24.703841649889625,
              -87.95705415209706,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T13:30:00Z',
              24.71837245118008,
              -87.98003150984486,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T13:45:00Z',
              24.734031386882435,
              -88.00479113032362,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T13:45:00Z',
              24.74531545204674,
              -88.02265927871345,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T14:00:00Z',
              24.76309347250691,
              -88.05080234425212,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T14:15:00Z',
              24.780913650367285,
              -88.07905617754449,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T14:15:00Z',
              24.79199099406478,
              -88.09658927625894,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T14:30:00Z',
              24.807647732276646,
              -88.12140815475514,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T14:30:00Z',
              24.796736458227844,
              -88.10408885316455,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T14:45:00Z',
              24.82744634058548,
              -88.15283744145566,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T14:45:00Z',
              24.838414684967308,
              -88.17025743660128,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T15:00:00Z',
              24.847867999709788,
              -88.18527854661514,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T15:15:00Z',
              24.873844659420293,
              -88.22200717446518,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T15:30:00Z',
              24.890410686138587,
              -88.24175428985147,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T15:30:00Z',
              24.894007679999998,
              -88.24604518,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T15:30:00Z',
              24.903549278241137,
              -88.2574205979149,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T15:45:00Z',
              24.92551753078449,
              -88.28361480342747,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T16:00:00Z',
              24.948862472575236,
              -88.31145814682273,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T16:00:00Z',
              24.961957775503368,
              -88.32709591543617,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T16:15:00Z',
              24.99135324384615,
              -88.35722241230769,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T16:15:00Z',
              24.976687774062963,
              -88.3443291275114,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T16:30:00Z',
              25.007318415259935,
              -88.372572216678,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T16:45:00Z',
              25.043293406693966,
              -88.40893746461741,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T16:45:00Z',
              25.029646139777483,
              -88.39416256522948,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T17:00:00Z',
              25.063182728829986,
              -88.43078571435038,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T17:15:00Z',
              25.095458937009543,
              -88.46396548197245,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T17:15:00Z',
              25.081258987977094,
              -88.44982648206098,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T17:30:00Z',
              25.10777284701757,
              -88.47635715824568,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T17:30:00Z',
              25.121775284446457,
              -88.49042963655539,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T17:45:00Z',
              25.147174948624503,
              -88.51597890804665,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T18:00:00Z',
              25.186160011111106,
              -88.55669161666667,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T18:00:00Z',
              25.17122699885414,
              -88.54089464514921,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T18:00:00Z',
              25.18390487727272,
              -88.55435857727285,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T18:15:00Z',
              25.198846318817935,
              -88.57071914938881,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T18:30:00Z',
              25.22106209425585,
              -88.59807590469981,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T18:45:00Z',
              25.25156533357399,
              -88.63641391588459,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T18:45:00Z',
              25.24058052428222,
              -88.62260519975382,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T19:00:00Z',
              25.26423958131485,
              -88.65235563840838,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T19:15:00Z',
              25.27634496435642,
              -88.66762789306928,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T19:15:00Z',
              25.287304902318404,
              -88.68138552102015,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T19:30:00Z',
              25.30376275641032,
              -88.70208782800009,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T19:30:00Z',
              25.31471240035906,
              -88.71588621831245,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T19:45:00Z',
              25.32957451078637,
              -88.73461369130129,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T20:00:00Z',
              25.35095392968435,
              -88.76154958905292,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T20:15:00Z',
              25.377999120998275,
              -88.79569564371774,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T20:15:00Z',
              25.37268027441861,
              -88.78899860077513,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T20:15:00Z',
              25.3665758050064,
              -88.78129302477524,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T20:30:00Z',
              25.39271013951777,
              -88.81421789678514,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T20:45:00Z',
              25.413155274270178,
              -88.84005870081455,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T21:00:00Z',
              25.43827125029308,
              -88.87175007667052,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T21:00:00Z',
              25.42807056478453,
              -88.85886760638934,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T21:15:00Z',
              25.448983613328956,
              -88.88541436823597,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T21:30:00Z',
              25.471764951269044,
              -88.91608180786807,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T21:30:00Z',
              25.462553536021517,
              -88.9029947790323,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T21:45:00Z',
              25.476519267322587,
              -88.9263808742094,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T22:00:00Z',
              25.49210838198532,
              -88.9513321864888,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T22:00:00Z',
              25.482819179202263,
              -88.93805910056973,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T22:15:00Z',
              25.507997300762337,
              -88.97408175322255,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T22:30:00Z',
              25.52614514019402,
              -89.0000699989606,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T22:45:00Z',
              25.5460408549307,
              -89.02855673675631,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T22:45:00Z',
              25.53692928021978,
              -89.01545810109894,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T23:00:00Z',
              25.56810576351085,
              -89.06021199467452,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T23:00:00Z',
              25.55929829739383,
              -89.04757636332063,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T23:15:00Z',
              25.57995736909343,
              -89.07720356105754,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T23:30:00Z',
              25.59906270762294,
              -89.10460819713103,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T23:30:00Z',
              25.59031930375939,
              -89.09205496578942,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-01T23:45:00Z',
              25.615097401105036,
              -89.12761013901925,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T00:00:00Z',
              25.63235339414965,
              -89.15241960897932,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T00:15:00Z',
              25.651301696804072,
              -89.1796364352399,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T00:15:00Z',
              25.64294254923076,
              -89.1676308135897,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T00:30:00Z',
              25.66739846943499,
              -89.20274823253376,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T00:30:00Z',
              25.659261818410048,
              -89.19105600334728,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T00:45:00Z',
              25.68252205835209,
              -89.22450809700348,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T01:00:00Z',
              25.69433393870965,
              -89.24150242459686,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T01:00:00Z',
              25.701871960557163,
              -89.25236030615837,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T01:15:00Z',
              25.713951453717332,
              -89.26976440776971,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T01:30:00Z',
              25.73081658010864,
              -89.29404389891383,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T01:45:00Z',
              25.744887802897225,
              -89.31430232289722,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T01:45:00Z',
              25.753090464208253,
              -89.32614393318867,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T02:00:00Z',
              25.755708981481476,
              -89.32992897222228,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T02:00:00Z',
              25.763697828199636,
              -89.34142690126599,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T02:15:00Z',
              25.779204081935884,
              -89.36377887702805,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T02:30:00Z',
              25.794845437965375,
              -89.38638600804505,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T02:45:00Z',
              25.80292648636365,
              -89.39805595606067,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T02:45:00Z',
              25.810682290060853,
              -89.40927163962154,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T03:00:00Z',
              25.825937833941072,
              -89.43133208457215,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T03:15:00Z',
              25.84125866536315,
              -89.45347154029352,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T03:30:00Z',
              25.853418433080808,
              -89.47104380631315,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T03:30:00Z',
              25.86011522539683,
              -89.48072732517014,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T03:30:00Z',
              25.85017187329843,
              -89.4663519497382,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T03:45:00Z',
              25.87226195907309,
              -89.49832348009178,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T04:00:00Z',
              25.887570508782428,
              -89.52048998316714,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T04:15:00Z',
              25.908955032799977,
              -89.5514688652,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T04:15:00Z',
              25.90163773785834,
              -89.54087638364227,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T04:30:00Z',
              25.917763907739726,
              -89.56424520246581,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T04:45:00Z',
              25.93265015478715,
              -89.58582869035892,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T05:00:00Z',
              25.94312571884059,
              -89.601043441868,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T05:00:00Z',
              25.95046118361583,
              -89.61167116293802,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T05:15:00Z',
              25.96451944680202,
              -89.63205665918794,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T05:15:00Z',
              25.95729431631878,
              -89.6215785371916,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T05:30:00Z',
              25.976640617508398,
              -89.64964589952864,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T05:45:00Z',
              25.99095432979483,
              -89.6704518400567,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T06:00:00Z',
              26.0048284456799,
              -89.69064876784374,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T06:00:00Z',
              26.012267663194454,
              -89.7014809090278,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T06:15:00Z',
              26.020483287913635,
              -89.71336816407847,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T06:30:00Z',
              26.042019332584292,
              -89.74465646235957,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T06:30:00Z',
              26.034675886785116,
              -89.73398226267398,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T06:45:00Z',
              26.050352722612352,
              -89.75678289698045,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T07:00:00Z',
              26.06773923418301,
              -89.78207515295487,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T07:00:00Z',
              26.060452397757032,
              -89.77146901308414,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T07:15:00Z',
              26.079410385972007,
              -89.79908524201734,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T07:30:00Z',
              26.0936272741713,
              -89.81980534502762,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T07:45:00Z',
              26.114913385999998,
              -89.85086860199999,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T07:45:00Z',
              26.107783642123742,
              -89.84045264845292,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T08:00:00Z',
              26.12237665269335,
              -89.86172366512422,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T08:15:00Z',
              26.1327134792342,
              -89.8767977135494,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T08:15:00Z',
              26.139864937760407,
              -89.88726505533852,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T08:30:00Z',
              26.150915276403694,
              -89.90340841272203,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T08:45:00Z',
              26.1690359711457,
              -89.9298705353606,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T08:45:00Z',
              26.1619676067081,
              -89.91955245913043,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T09:00:00Z',
              26.179398160869486,
              -89.94503534735041,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T09:15:00Z',
              26.193575207241654,
              -89.96574909144174,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T09:30:00Z',
              26.207601096158882,
              -89.98628295854309,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T09:45:00Z',
              26.222954790916233,
              -90.00872408041067,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T09:45:00Z',
              26.215801781557342,
              -89.99826013770489,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T10:00:00Z',
              26.229633123952095,
              -90.01846851077838,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T10:00:00Z',
              26.236738763495712,
              -90.02888961647326,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T10:15:00Z',
              26.24829376220572,
              -90.04957840793548,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T10:30:00Z',
              26.25790761816883,
              -90.08063647210308,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T10:30:00Z',
              26.25423702050316,
              -90.06843415672932,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T10:45:00Z',
              26.262762759919585,
              -90.09923720395462,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T11:00:00Z',
              26.273747936869057,
              -90.12250622443311,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T11:15:00Z',
              26.29498404166664,
              -90.15138251231885,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T11:15:00Z',
              26.287514994468097,
              -90.14128952323426,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T11:30:00Z',
              26.30417117840985,
              -90.16385064948598,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T11:45:00Z',
              26.318384281245002,
              -90.18335115602842,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T11:45:00Z',
              26.325882813270134,
              -90.1935951502369,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T12:00:00Z',
              26.334513644154924,
              -90.2054463571831,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T12:15:00Z',
              26.35257120575124,
              -90.23046538251171,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T12:15:00Z',
              26.34519553254348,
              -90.22022078483417,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T12:30:00Z',
              26.364401962033142,
              -90.24689413174274,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T12:45:00Z',
              26.37955654847481,
              -90.26783051909808,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T13:00:00Z',
              26.394558496682425,
              -90.28832326052806,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T13:15:00Z',
              26.409904244555893,
              -90.30941439233528,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T13:15:00Z',
              26.40240985441177,
              -90.29911295588234,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T13:30:00Z',
              26.4180374209424,
              -90.32054593979059,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T13:30:00Z',
              26.425248920609466,
              -90.33059634675215,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T13:45:00Z',
              26.43859775265665,
              -90.3492210137602,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T14:00:00Z',
              26.451550281971596,
              -90.36719241083469,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T14:00:00Z',
              26.458662573118268,
              -90.37718324973122,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T14:15:00Z',
              26.467946521941204,
              -90.39015721578961,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T14:30:00Z',
              26.484142457062458,
              -90.41076268496138,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T14:45:00Z',
              26.50119212595664,
              -90.43070995924752,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T15:00:00Z',
              26.51556677226108,
              -90.44748428764575,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T15:00:00Z',
              26.511405798753895,
              -90.44263009532725,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T15:00:00Z',
              26.519672722166273,
              -90.45259905843842,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T15:15:00Z',
              26.527270559428928,
              -90.4641185310093,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T15:30:00Z',
              26.54411204429521,
              -90.48468561765108,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T15:45:00Z',
              26.560690967437296,
              -90.5049321859973,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T16:00:00Z',
              26.581654193203875,
              -90.53086306685164,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T16:00:00Z',
              26.57342026015223,
              -90.5205102596448,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T16:15:00Z',
              26.592715962676518,
              -90.54704289213184,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T16:30:00Z',
              26.60362330136162,
              -90.56329644810889,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T16:30:00Z',
              26.61114615624997,
              -90.57449391238204,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T16:45:00Z',
              26.62973621122448,
              -90.60219355918366,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T16:45:00Z',
              26.62223722929431,
              -90.59099896457595,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T17:00:00Z',
              26.63770877508034,
              -90.61410388092477,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T17:15:00Z',
              26.652536569746236,
              -90.63625284020823,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T17:30:00Z',
              26.667238478609317,
              -90.65820810026486,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T17:45:00Z',
              26.67726240942764,
              -90.67320401969693,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T17:45:00Z',
              26.684485785257156,
              -90.68399698914277,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T18:00:00Z',
              26.70209997403098,
              -90.71032558837213,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T18:00:00Z',
              26.694851539448713,
              -90.69949521481473,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T18:15:00Z',
              26.7109960356307,
              -90.72361900689222,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T18:30:00Z',
              26.731888979310337,
              -90.75484793103443,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T18:30:00Z',
              26.72436983011703,
              -90.74362342923986,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T18:45:00Z',
              26.74050768531752,
              -90.76773341408739,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T19:00:00Z',
              26.75525388974016,
              -90.78979145876085,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T19:15:00Z',
              26.77258334871796,
              -90.81577233824773,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T19:30:00Z',
              26.787172226434603,
              -90.8376468720603,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T19:30:00Z',
              26.77971694231737,
              -90.8264613309825,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T19:45:00Z',
              26.799861912510774,
              -90.85663537981021,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T19:45:00Z',
              26.792704081029825,
              -90.84588028834688,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T20:00:00Z',
              26.812666855933387,
              -90.87586448133335,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T20:15:00Z',
              26.83369913506493,
              -90.90742342251086,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T20:15:00Z',
              26.826335769755676,
              -90.89638584945257,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T20:30:00Z',
              26.842631585312276,
              -90.92087492422773,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T20:45:00Z',
              26.857879840143333,
              -90.94378027247298,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T21:00:00Z',
              26.872708106542728,
              -90.96605340902202,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T21:15:00Z',
              26.891699438709654,
              -90.99459499445179,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T21:15:00Z',
              26.88545755335119,
              -90.98520209597861,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T21:15:00Z',
              26.88199649166667,
              -90.97999345869567,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T21:30:00Z',
              26.900517886467753,
              -91.00940176426083,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T21:45:00Z',
              26.90715460467222,
              -91.02640167231537,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T22:00:00Z',
              26.91736302717092,
              -91.04178132836148,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T22:15:00Z',
              26.923966187887313,
              -91.05260511795761,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T22:30:00Z',
              26.92170074304536,
              -91.05362064004402,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T22:45:00Z',
              26.921604131000013,
              -91.05945903400003,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T22:45:00Z',
              26.919306401478195,
              -91.05508248226175,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T23:00:00Z',
              26.93072990747476,
              -91.07271877043765,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T23:15:00Z',
              26.947657900000063,
              -91.09735230254692,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T23:30:00Z',
              26.96457878956237,
              -91.12198879070696,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T23:45:00Z',
              26.985447262200957,
              -91.15237434342102,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T23:45:00Z',
              26.977046568466925,
              -91.14015938466909,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-02T23:45:00Z',
              26.97342118461539,
              -91.13488220769227,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T00:00:00Z',
              26.99937199079751,
              -91.17264471540541,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T00:15:00Z',
              27.016748428764334,
              -91.1979764691426,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T00:30:00Z',
              27.034009148588385,
              -91.22315676612189,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T00:30:00Z',
              27.025635053333346,
              -91.21092985799999,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T00:45:00Z',
              27.049630138929754,
              -91.24598725785945,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T01:00:00Z',
              27.06584667663128,
              -91.26968756896805,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T01:00:00Z',
              27.074665039455784,
              -91.28256304217686,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T01:15:00Z',
              27.08644317336134,
              -91.29978714470587,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T01:15:00Z',
              27.077389871134027,
              -91.2865521178694,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T01:30:00Z',
              27.102104104479636,
              -91.322690936166,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T01:45:00Z',
              27.118829753477655,
              -91.34716882020989,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T02:00:00Z',
              27.137795460856854,
              -91.37492433807215,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T02:00:00Z',
              27.129381830281684,
              -91.36260959131455,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T02:15:00Z',
              27.152806070939555,
              -91.39689083966462,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T02:30:00Z',
              27.173040227602254,
              -91.42653896784388,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T02:30:00Z',
              27.16421180227275,
              -91.41359796818188,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T02:45:00Z',
              27.182256355023938,
              -91.44003890382777,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T02:45:00Z',
              27.191113971924878,
              -91.4530404794366,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T03:00:00Z',
              27.20613836444295,
              -91.47509071354237,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T03:15:00Z',
              27.224090223433233,
              -91.50144407213902,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T03:30:00Z',
              27.235202430747908,
              -91.51773492991683,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T03:30:00Z',
              27.244081136561107,
              -91.53079107773745,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T03:45:00Z',
              27.254763057065922,
              -91.54649687994618,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T03:45:00Z',
              27.263432633288804,
              -91.55924956136379,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T04:00:00Z',
              27.27607122040126,
              -91.57785019424736,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T04:15:00Z',
              27.295237917286432,
              -91.60607757819093,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T04:15:00Z',
              27.28722352820512,
              -91.59426693424903,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T04:30:00Z',
              27.30741925790549,
              -91.62582755325123,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T04:45:00Z',
              27.322360255941597,
              -91.65097099722014,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T05:00:00Z',
              27.333570216338025,
              -91.66983906704228,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T05:00:00Z',
              27.341212856611488,
              -91.6826997084023,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T05:15:00Z',
              27.355721950167272,
              -91.70715754749162,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T05:15:00Z',
              27.348344868102085,
              -91.69473765438597,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T05:30:00Z',
              27.36761474942843,
              -91.72715267081364,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T05:45:00Z',
              27.379154458294447,
              -91.74662364929908,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T05:45:00Z',
              27.386629052884636,
              -91.75925760608969,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T06:00:00Z',
              27.39746735298698,
              -91.77758317331167,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T06:15:00Z',
              27.4127531620599,
              -91.80336212132885,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T06:30:00Z',
              27.425001832566203,
              -91.82404484994248,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T06:30:00Z',
              27.43277830950868,
              -91.8371755676704,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T06:45:00Z',
              27.43963118273097,
              -91.84877658072293,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T06:45:00Z',
              27.44731030945084,
              -91.8617589911877,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T07:00:00Z',
              27.458831609829648,
              -91.88124596631721,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T07:15:00Z',
              27.47881934271686,
              -91.91506957610468,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T07:15:00Z',
              27.47119944999999,
              -91.90216522197808,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T07:30:00Z',
              27.489795982790667,
              -91.93368385574755,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T07:45:00Z',
              27.50579734388774,
              -91.96081224856368,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T08:00:00Z',
              27.525884473071716,
              -91.99487698037896,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T08:00:00Z',
              27.517877628571462,
              -91.98129973299636,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T08:15:00Z',
              27.532546186601916,
              -92.00615872155343,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T08:15:00Z',
              27.540488145015054,
              -92.0196492629406,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T08:30:00Z',
              27.553552827320274,
              -92.04183777647049,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T08:45:00Z',
              27.564783455047348,
              -92.06091891435348,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T08:45:00Z',
              27.572640955948515,
              -92.07428982904592,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T09:00:00Z',
              27.585049466404207,
              -92.09537213576134,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T09:15:00Z',
              27.600733613642735,
              -92.12200143421049,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T09:30:00Z',
              27.61144241615386,
              -92.1402406265385,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T09:30:00Z',
              27.619338759722222,
              -92.15368222419004,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T09:45:00Z',
              27.625584769154255,
              -92.16428123283576,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T09:45:00Z',
              27.63329387765319,
              -92.17739224693695,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T10:00:00Z',
              27.647537352280104,
              -92.20167818859946,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T10:15:00Z',
              27.66505609654379,
              -92.23223924124417,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T10:15:00Z',
              27.65785127305824,
              -92.2192508978155,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T10:30:00Z',
              27.676678142351406,
              -92.25393403687393,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T10:45:00Z',
              27.691214189769866,
              -92.27938664392597,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T11:00:00Z',
              27.703204304148752,
              -92.29701537711014,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T11:00:00Z',
              27.711586236290348,
              -92.30919130875566,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T11:15:00Z',
              27.72557396995105,
              -92.3291158153043,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T11:15:00Z',
              27.717139352564093,
              -92.31717147371796,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T11:30:00Z',
              27.741563801134934,
              -92.35147273451265,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T11:45:00Z',
              27.756195028499132,
              -92.37209787082618,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T11:45:00Z',
              27.764041781786972,
              -92.38353290859108,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T12:00:00Z',
              27.773416353617524,
              -92.39730263391465,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T12:15:00Z',
              27.789291644430175,
              -92.42059575339313,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T12:30:00Z',
              27.811304956936436,
              -92.4527482748555,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T12:30:00Z',
              27.803223398863633,
              -92.44095970121718,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T12:45:00Z',
              27.822358842264684,
              -92.46982404641155,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T12:45:00Z',
              27.81479443952801,
              -92.45784711091449,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T13:00:00Z',
              27.835726043855157,
              -92.49152270446321,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T13:15:00Z',
              27.850310998187936,
              -92.51558284395946,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T13:30:00Z',
              27.868525055923637,
              -92.5455937411467,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T13:30:00Z',
              27.861306401988603,
              -92.53367826548286,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T13:45:00Z',
              27.879358520159656,
              -92.56388985156342,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T14:00:00Z',
              27.892823169251432,
              -92.58790869365001,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T14:15:00Z',
              27.900127321052633,
              -92.60127710263158,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T14:15:00Z',
              27.905038774837276,
              -92.61022232245118,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T14:15:00Z',
              27.911626290055235,
              -92.62244833121552,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T14:30:00Z',
              27.91997396405865,
              -92.63857520513456,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T14:45:00Z',
              27.933523090500415,
              -92.6657312948512,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T15:00:00Z',
              27.94434723372483,
              -92.68835148447987,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T15:00:00Z',
              27.950680720116598,
              -92.70134998513122,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T15:15:00Z',
              27.960653620893613,
              -92.7155956076216,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T15:30:00Z',
              27.981043827831478,
              -92.73573206602242,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T15:45:00Z',
              28.00120753480359,
              -92.75525132632659,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T15:45:00Z',
              27.9912357,
              -92.74560750833335,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T16:00:00Z',
              28.017982476310504,
              -92.77150850776206,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T16:00:00Z',
              28.02775960250522,
              -92.7809965219206,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T16:15:00Z',
              28.0400949939815,
              -92.79295026183841,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T16:30:00Z',
              28.061391150661333,
              -92.80641447870362,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T16:45:00Z',
              28.07853090257573,
              -92.81217479484832,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T16:45:00Z',
              28.089838181351908,
              -92.81541391188803,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T17:00:00Z',
              28.106427839174536,
              -92.82223687050063,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T17:15:00Z',
              28.11955178184284,
              -92.82622328374005,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T17:30:00Z',
              28.134885868244492,
              -92.84112723379369,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T17:45:00Z',
              28.158140534266668,
              -92.86094127279993,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T17:45:00Z',
              28.148940912549513,
              -92.85376801175678,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T18:00:00Z',
              28.164099747361416,
              -92.86290516299262,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T18:15:00Z',
              28.166004462080636,
              -92.87666331899325,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T18:30:00Z',
              28.170624802957025,
              -92.90685419939494,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T18:45:00Z',
              28.174065504778174,
              -92.94068686723541,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T18:45:00Z',
              28.174821983372365,
              -92.94817558571427,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T18:45:00Z',
              28.17303269435261,
              -92.92977434862257,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T19:00:00Z',
              28.173449533758003,
              -92.97502033216557,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T19:00:00Z',
              28.1752869636214,
              -92.96198455835382,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T19:15:00Z',
              28.168498903395477,
              -92.98783293175754,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T19:30:00Z',
              28.155375395663924,
              -92.98612949939042,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T19:45:00Z',
              28.149934036381946,
              -92.98345065854478,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T20:00:00Z',
              28.166404890281047,
              -92.99095950714272,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T20:00:00Z',
              28.176701398267742,
              -92.99648581858273,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T20:15:00Z',
              28.193910542290748,
              -93.02098753788557,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T20:15:00Z',
              28.185978056586272,
              -93.0096669068647,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T20:30:00Z',
              28.20498762732605,
              -93.03651750221239,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T20:45:00Z',
              28.222779962241013,
              -93.0609262856865,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T21:00:00Z',
              28.2414409426764,
              -93.08525203894783,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T21:15:00Z',
              28.265266219574478,
              -93.11840175276599,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T21:15:00Z',
              28.257721365817602,
              -93.1064470095318,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T21:15:00Z',
              28.251109726315786,
              -93.09754487368424,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T21:30:00Z',
              28.274637340597252,
              -93.13311501499368,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T21:45:00Z',
              28.29035879199485,
              -93.16006384796674,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T22:00:00Z',
              28.299235816315807,
              -93.17616625157902,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T22:00:00Z',
              28.308179879034615,
              -93.1900602001511,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T22:15:00Z',
              28.325216842101838,
              -93.21697161767058,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T22:30:00Z',
              28.3414792123894,
              -93.24481318543853,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T22:30:00Z',
              28.350524628676453,
              -93.25983493014712,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T22:45:00Z',
              28.352719751794847,
              -93.26347029589742,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T22:45:00Z',
              28.363859964124497,
              -93.2761232599222,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T23:00:00Z',
              28.384484515298766,
              -93.30080488220615,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T23:15:00Z',
              28.405897646723226,
              -93.32680426877403,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T23:15:00Z',
              28.41724279731184,
              -93.34060119731178,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T23:30:00Z',
              28.429850345424427,
              -93.3558119187001,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T23:45:00Z',
              28.450293664324867,
              -93.38954411067539,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-03T23:45:00Z',
              28.44228687446808,
              -93.37390880496461,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T00:00:00Z',
              28.46855415596868,
              -93.42518799315062,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T00:00:00Z',
              28.460776946844952,
              -93.41001801229952,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T00:15:00Z',
              28.4791748502032,
              -93.4459210838076,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T00:30:00Z',
              28.49660729325698,
              -93.47464596567757,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T00:45:00Z',
              28.509833202058296,
              -93.49464746912531,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T00:45:00Z',
              28.519126685981323,
              -93.5086816609813,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T01:00:00Z',
              28.529398152349007,
              -93.52419145879202,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T01:00:00Z',
              28.538583752781697,
              -93.53807643352341,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T01:15:00Z',
              28.552464652572528,
              -93.55907652605555,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T01:30:00Z',
              28.573703649525648,
              -93.59122497922193,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T01:30:00Z',
              28.56443545165882,
              -93.5772079542655,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T01:45:00Z',
              28.589214909749664,
              -93.61473234229263,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T02:00:00Z',
              28.606798485196894,
              -93.64139450711549,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T02:15:00Z',
              28.62243802951543,
              -93.66414817841407,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T02:15:00Z',
              28.618247912719298,
              -93.65838480394737,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T02:15:00Z',
              28.62906285199036,
              -93.67324680349834,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T02:30:00Z',
              28.644186389716545,
              -93.69401782320374,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T02:45:00Z',
              28.663495902053377,
              -93.72055693449705,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T03:00:00Z',
              28.676738048114885,
              -93.73877518761226,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T03:00:00Z',
              28.68632089028179,
              -93.75197817453841,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T03:15:00Z',
              28.702070454736166,
              -93.77365888162747,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T03:30:00Z',
              28.7126056578313,
              -93.7881367102409,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T03:30:00Z',
              28.721997459025694,
              -93.80106060093131,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T03:45:00Z',
              28.744297007738055,
              -93.83178503916673,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T03:45:00Z',
              28.734987423365784,
              -93.81894887816414,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T04:00:00Z',
              28.758800018936444,
              -93.85176685363176,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T04:15:00Z',
              28.77762046223234,
              -93.87771998507473,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T04:30:00Z',
              28.79252982414534,
              -93.89828675705147,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T04:30:00Z',
              28.80412634039732,
              -93.91432200728478,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T04:30:00Z',
              28.80079273443396,
              -93.90973972311322,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T04:45:00Z',
              28.814103746634974,
              -93.92810711101285,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T05:00:00Z',
              28.83276925885904,
              -93.95391522677845,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T05:15:00Z',
              28.84968040264428,
              -93.97728559831742,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T05:15:00Z',
              28.859235083056483,
              -93.99052351495017,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T05:30:00Z',
              28.87067138095548,
              -94.00634630523565,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T05:45:00Z',
              28.895092206302543,
              -94.04073370042026,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T05:45:00Z',
              28.886377948470813,
              -94.02825778971246,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T06:00:00Z',
              28.906081139335875,
              -94.05648431819928,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T06:15:00Z',
              28.914867258064515,
              -94.06909965322576,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T06:15:00Z',
              28.923358392752718,
              -94.08132526635644,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T06:30:00Z',
              28.939826985413937,
              -94.10497629286634,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T06:45:00Z',
              28.956787839658652,
              -94.1293809284308,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T07:00:00Z',
              28.976969504000028,
              -94.15839086635316,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T07:00:00Z',
              28.96880484928828,
              -94.14664327900364,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T07:00:00Z',
              28.98235047238095,
              -94.16612961238097,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T07:15:00Z',
              28.991613946788394,
              -94.17946178607183,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T07:30:00Z',
              29.0089496291302,
              -94.20440927296006,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T07:45:00Z',
              29.023267473054478,
              -94.2250395684825,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T07:45:00Z',
              29.031956595294115,
              -94.2375648096079,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T08:00:00Z',
              29.043821716797396,
              -94.25463575333337,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T08:15:00Z',
              29.061477983635168,
              -94.27983419469591,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T08:30:00Z',
              29.070463992000008,
              -94.29235620400003,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T08:30:00Z',
              29.087730974999992,
              -94.31635043879304,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T08:30:00Z',
              29.07892317953749,
              -94.30411518857744,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T08:45:00Z',
              29.097424014977303,
              -94.32976046875407,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T09:00:00Z',
              29.115391291149816,
              -94.35364171350137,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T09:15:00Z',
              29.132311082562033,
              -94.37704617062357,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T09:30:00Z',
              29.143724433171514,
              -94.39312354417477,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T09:30:00Z',
              29.151855788470296,
              -94.40465903801355,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T09:45:00Z',
              29.16609406744192,
              -94.42510499883694,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T09:45:00Z',
              29.15819533253968,
              -94.41376934960326,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T10:00:00Z',
              29.18067928484654,
              -94.44614213005117,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T10:15:00Z',
              29.19678903887816,
              -94.4687578500965,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T10:15:00Z',
              29.205393603225815,
              -94.48019615483872,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T10:30:00Z',
              29.214123457712112,
              -94.49201491478156,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T10:45:00Z',
              29.230995615354765,
              -94.5156860945162,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T11:00:00Z',
              29.25486425539903,
              -94.5425814309859,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T11:00:00Z',
              29.244024632971506,
              -94.53273188819541,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T11:15:00Z',
              29.276439193439703,
              -94.56717324202131,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T11:15:00Z',
              29.267327692166905,
              -94.55484648708065,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T11:30:00Z',
              29.287591550098412,
              -94.58467629318027,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T11:45:00Z',
              29.304890514048466,
              -94.61169615792421,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T12:00:00Z',
              29.324199802684575,
              -94.64759779328858,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T12:00:00Z',
              29.31869649521874,
              -94.63451487066447,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T12:15:00Z',
              29.33732978388627,
              -94.67364292464448,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T12:15:00Z',
              29.33067995998472,
              -94.66080374603638,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T12:30:00Z',
              29.343896130437628,
              -94.69049481685182,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T12:45:00Z',
              29.35005147408872,
              -94.71687612551729,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T12:45:00Z',
              29.35122827157253,
              -94.73278565987903,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T13:00:00Z',
              29.35075392110352,
              -94.75306620206901,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T13:15:00Z',
              29.3560890329027,
              -94.77971573161108,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T13:30:00Z',
              29.376324413651595,
              -94.79571390625429,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T13:45:00Z',
              29.394275516733586,
              -94.80669061137891,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T13:45:00Z',
              29.4068063103079,
              -94.81417762556887,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T14:00:00Z',
              29.429487714884942,
              -94.82675866224638,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T14:00:00Z',
              29.418230539597293,
              -94.82097748067129,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T14:15:00Z',
              29.447249627076122,
              -94.8348758283319,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T14:30:00Z',
              29.471815721355263,
              -94.84600840095858,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T14:45:00Z',
              29.496668084970654,
              -94.85696677534165,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T15:00:00Z',
              29.523179888797078,
              -94.87375228383846,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T15:00:00Z',
              29.511771299501248,
              -94.86546854987536,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T15:15:00Z',
              29.543148256430467,
              -94.89719468188963,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T15:15:00Z',
              29.538837396136568,
              -94.88584109263248,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T15:30:00Z',
              29.54331275456376,
              -94.91542439335579,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T15:45:00Z',
              29.546128569852005,
              -94.94498717530287,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T16:00:00Z',
              29.549678470613436,
              -94.98335781954349,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T16:00:00Z',
              29.54813942969771,
              -94.96855129973699,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T16:15:00Z',
              29.55067224778523,
              -94.99965081268452,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T16:30:00Z',
              29.548258022511643,
              -95.01722014549082,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T16:45:00Z',
              29.54612187554418,
              -95.0200948371017,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T17:00:00Z',
              29.546119844932647,
              -95.02006787859811,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T17:15:00Z',
              29.546122492878432,
              -95.0200713565773,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T17:30:00Z',
              29.54612668664859,
              -95.02006543242564,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T17:45:00Z',
              29.546132132449063,
              -95.02006932988486,
              NULL,
              NULL,
              NULL
            );
          

            INSERT OR REPLACE INTO passage_positions (passage_id, time, lat, lon, speed, heading, distance)
            VALUES (
              'tideye_passage_2025_06_26',
              '2025-07-04T18:00:00Z',
              29.546136172477766,
              -95.02007597858449,
              NULL,
              NULL,
              NULL
            );
          