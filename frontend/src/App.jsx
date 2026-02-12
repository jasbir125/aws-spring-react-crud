import React, { useState } from 'react';
import './App.css';
import ItemList from './components/ItemList';
import ItemForm from './components/ItemForm';
import { createItem, updateItem } from './services/api';

function App() {
  const [currentItem, setCurrentItem] = useState(null);
  const [refreshTrigger, setRefreshTrigger] = useState(0);

  const handleSave = async (item) => {
    try {
      if (item.id) {
        await updateItem(item.id, item);
      } else {
        await createItem(item);
      }
      setCurrentItem(null);
      setRefreshTrigger(prev => prev + 1);
    } catch (error) {
      console.error("Error saving item:", error);
      alert("Failed to save item.");
    }
  };

  const handleEdit = (item) => {
    setCurrentItem(item);
  };

  const handleCancel = () => {
    setCurrentItem(null);
  };

  return (
    <div className="app-container">
      <header className="app-header">
        <h1>Spring Boot + React CRUD</h1>
      </header>
      <main className="app-main">
        <section className="form-section">
          <ItemForm
            currentItem={currentItem}
            onSave={handleSave}
            onCancel={handleCancel}
          />
        </section>
        <section className="list-section">
          <ItemList
            onEdit={handleEdit}
            refreshTrigger={refreshTrigger}
          />
        </section>
      </main>
    </div>
  );
}

export default App;
