import ContentManager from './ContentManager';

export default function Verses() {
  return (
    <ContentManager
      tableName="verses"
      title="Quran Verses"
      subtitle="Manage daily Quran verses mapped to the Hijri calendar"
      contentLabel="Verse"
    />
  );
}
