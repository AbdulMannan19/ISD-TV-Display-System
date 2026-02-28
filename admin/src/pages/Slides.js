import React, { useState, useEffect } from 'react';
import { supabase } from '../supabase';

export default function Slides() {
  const [slides, setSlides] = useState([]);
  const [uploading, setUploading] = useState(false);

  const fetchSlides = async () => {
    const { data } = await supabase.from('slides').select('*').order('display_order');
    if (data) setSlides(data);
  };

  useEffect(() => { fetchSlides(); }, []);

  const handleUpload = async (e) => {
    const file = e.target.files[0];
    if (!file) return;
    setUploading(true);

    const fileName = `${Date.now()}-${file.name}`;
    const { error: uploadError } = await supabase.storage.from('slides').upload(fileName, file);

    if (uploadError) {
      alert(uploadError.message);
      setUploading(false);
      return;
    }

    const { data: { publicUrl } } = supabase.storage.from('slides').getPublicUrl(fileName);
    const maxOrder = slides.length > 0 ? Math.max(...slides.map(s => s.display_order)) : 0;

    await supabase.from('slides').insert({
      image_url: publicUrl,
      display_order: maxOrder + 1,
    });

    setUploading(false);
    e.target.value = '';
    fetchSlides();
  };

  const toggleActive = async (slide) => {
    await supabase.from('slides').update({ is_active: !slide.is_active }).eq('id', slide.id);
    fetchSlides();
  };

  const updateDuration = async (slide, duration) => {
    await supabase.from('slides').update({ duration_seconds: parseInt(duration) || 10 }).eq('id', slide.id);
  };

  const deleteSlide = async (slide) => {
    const fileName = slide.image_url.split('/').pop();
    await supabase.storage.from('slides').remove([fileName]);
    await supabase.from('slides').delete().eq('id', slide.id);
    fetchSlides();
  };

  return (
    <div>
      <h2>Slides</h2>
      <div className="upload-area" style={{ marginTop: 16 }}>
        <input type="file" accept="image/*" onChange={handleUpload} disabled={uploading} />
        {uploading && <span>Uploading...</span>}
      </div>
      {slides.map(slide => (
        <div className="slide-card" key={slide.id}>
          <img src={slide.image_url} alt={`Slide ${slide.id}`} />
          <div className="slide-info">
            <div>Order: {slide.display_order}</div>
            <div>
              Duration:
              <input
                type="number"
                defaultValue={slide.duration_seconds}
                onBlur={e => updateDuration(slide, e.target.value)}
                style={{ width: 60, marginLeft: 6 }}
              />s
            </div>
          </div>
          <div className="slide-actions">
            <button onClick={() => toggleActive(slide)}>
              {slide.is_active ? 'Disable' : 'Enable'}
            </button>
            <button className="delete" onClick={() => deleteSlide(slide)}>Delete</button>
          </div>
        </div>
      ))}
      {slides.length === 0 && <p>No slides yet. Upload one above.</p>}
    </div>
  );
}
