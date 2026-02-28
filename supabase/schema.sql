CREATE TABLE prayer_times (
  id INT PRIMARY KEY DEFAULT 1,
  fajr TIME NOT NULL,
  fajr_iqamah TIME NOT NULL,
  dhuhr TIME NOT NULL,
  dhuhr_iqamah TIME NOT NULL,
  asr TIME NOT NULL,
  asr_iqamah TIME NOT NULL,
  maghrib TIME NOT NULL,
  maghrib_iqamah TIME NOT NULL,
  isha TIME NOT NULL,
  isha_iqamah TIME NOT NULL,
  jumuah_1 TIME,
  jumuah_2 TIME,
  CONSTRAINT single_row CHECK (id = 1)
);

CREATE TABLE daily_info (
  id INT PRIMARY KEY DEFAULT 1,
  english_date DATE NOT NULL DEFAULT CURRENT_DATE,
  arabic_date TEXT,
  sunrise TIME NOT NULL,
  sunset TIME NOT NULL,
  CONSTRAINT single_row CHECK (id = 1)
);

CREATE TABLE slides (
  id INT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
  image_url TEXT NOT NULL,
  display_order INT NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true,
  duration_seconds INT NOT NULL DEFAULT 10
);

INSERT INTO prayer_times (fajr, fajr_iqamah, dhuhr, dhuhr_iqamah, asr, asr_iqamah, maghrib, maghrib_iqamah, isha, isha_iqamah, jumuah_1, jumuah_2)
VALUES ('05:49', '06:15', '12:41', '13:00', '15:56', '16:15', '18:25', '18:35', '19:33', '20:00', '13:45', '13:45');

INSERT INTO daily_info (english_date, arabic_date, sunrise, sunset)
VALUES ('2026-02-28', 'Ramadan 11, 1447', '06:58', '18:25');

ALTER PUBLICATION supabase_realtime ADD TABLE prayer_times;
ALTER PUBLICATION supabase_realtime ADD TABLE daily_info;
ALTER PUBLICATION supabase_realtime ADD TABLE slides;

INSERT INTO storage.buckets (id, name, public) VALUES ('slides', 'slides', true);
