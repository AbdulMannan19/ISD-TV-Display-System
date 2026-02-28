import React, { useState, useEffect, useRef } from 'react';
import { supabase } from '../supabase';

const MAX_SIZE = 2 * 1024 * 1024; // 2MB

export default function Slides() {
  const [slides, setSlides] = useState([]);
  const [uploading, setUploading] = useState(false);
  const [replacing, setReplacing] = useState(null);
  const uploadRef = useRef();
  const replaceRef = useRef();

  const fetchSlides = async () => {
    const { data } = await supabase.from('slides').select('*').order('display_order');
    if (data) setSlides(data);
  };

  useEffect(() => { fetchSlides(); }, []);

  const validateFile = (file) => {
    if (!['image/png', 'image/jpeg'].includes(file.type)) {
      alert('Only PNG and JPEG files are allowed.');
      return false;
    }
    if (file.size > MAX_SIZE) {
      alert('File size must be under 2MB.');
      return false;
    }
    return true;
  };

  const uploadFile = async (file) => {
    const fileName = `${Date.now()}-${file.name}`;
    const { error } = await supabase.storage.from('slides').upload(fileName, file);
    if (error) { alert(error.message); return null; }
    const { data: { publicUrl } } = supabase.storage.from('slides').getPublicUrl(fileName);
    return publicUrl;
  };

  const handleUpload = async (e) => {
    const file = e.target.files[0];
    if (!file || !validateFile(file)) return;
    setUploading(true);
    const url = await uploadFile(file);
    if (url) {
      const maxOrder = slides.length > 0 ? Math.max(...slides.map(s => s.display_order)) : 0;
      await supabase.from('slides').insert({ image_url: url, display_order: maxOrder + 1 });
      fetchSlides();
    }
    setUploading(false);
    e.target.value = '';
  };

  const handleReplace = async (e, slide) => {
    const file = e.target.files[0];
    if (!file || !validateFile(file)) return;
    setReplacing(slide.id);

    // Delete old file
    const oldName = slide.image_url.split('/').pop();
    await supabase.storage.from('slides').remove([oldName]);

    // Upload new
    const url = await uploadFile(file);
    if (url) {
      await supabase.from('slides').update({ image_url: url }).eq('id', slide.id);
      fetchSlides();
    }
    setReplacing(null);
    e.target.value = '';
  };

  const deleteSlide = async (slide) => {
    const fileName = slide.image_url.split('/').pop();
    await supabase.storage.from('slides').remove([fileName]);
    await supabase.from('slides').delete().eq('id', slide.id);
    fetchSlides();
  };

  return (
    <div>
      <h1 className="page-title">Slides</h1>

      <div className="slides-note">
        Recommended: PNG or JPEG, 1920×1080px (Full HD), max 2MB per image.
      </div>

      <div className="upload-zone" onClick={() => uploadRef.current?.click()}>
        <input type="file" accept="image/png,image/jpeg" ref={uploadRef} onChange={handleUpload} disabled={uploading} />
        <div className="upload-icon">📁</div>
        <p>{uploading ? 'Uploading...' : 'Click to upload a new slide'}</p>
      </div>

      {slides.map((slide, i) => (
        <div className="slide-display-card" key={slide.id}>
          <div className="slide-number">Slide {i + 1}</div>
          <img src={slide.image_url} alt={`Slide ${i + 1}`} />
          <div className="slide-card-actions">
            <input
              type="file"
              accept="image/png,image/jpeg"
              ref={slide.id === replacing ? replaceRef : undefined}
              style={{ display: 'none' }}
              onChange={e => handleReplace(e, slide)}
              id={`replace-${slide.id}`}
            />
            <button
              className="btn btn-outline btn-sm"
              onClick={() => document.getElementById(`replace-${slide.id}`).click()}
              disabled={replacing === slide.id}
            >
              {replacing === slide.id ? 'Replacing...' : '🔄 Replace'}
            </button>
            <button className="btn btn-danger btn-sm" onClick={() => deleteSlide(slide)}>🗑️ Delete</button>
          </div>
        </div>
      ))}

      {slides.length === 0 && (
        <div className="empty">
          <div className="empty-icon">🖼️</div>
          <p>No slides yet. Upload your first one above.</p>
        </div>
      )}
    </div>
  );
}
