import { useState, useCallback } from 'react';
import { useQuery } from '@tanstack/react-query';
import { carsApi } from '../services/api';

export interface SelectedVehicle {
  makeId: number;
  makeName: string;
  modelId: number;
  modelName: string;
  year?: number;
}

export function useVehicleSelection() {
  const [selectedMakeId, setSelectedMakeId] = useState<number | null>(null);
  const [selectedModelId, setSelectedModelId] = useState<number | null>(null);
  const [selectedYear, setSelectedYear] = useState<number | null>(null);

  // Fetch makes
  const { data: makes, isLoading: makesLoading, error: makesError } = useQuery({
    queryKey: ['makes'],
    queryFn: carsApi.getMakes,
  });

  // Fetch models based on selected make
  const { data: models, isLoading: modelsLoading } = useQuery({
    queryKey: ['models', selectedMakeId],
    queryFn: () => carsApi.getModels(selectedMakeId!),
    enabled: !!selectedMakeId,
  });

  // Fetch years based on selected model
  const { data: years, isLoading: yearsLoading } = useQuery({
    queryKey: ['years', selectedModelId],
    queryFn: () => carsApi.getYears(selectedModelId!),
    enabled: !!selectedModelId,
  });

  const handleMakeChange = useCallback((makeId: number | null) => {
    setSelectedMakeId(makeId);
    setSelectedModelId(null);
    setSelectedYear(null);
  }, []);

  const handleModelChange = useCallback((modelId: number | null) => {
    setSelectedModelId(modelId);
    setSelectedYear(null);
  }, []);

  const handleYearChange = useCallback((year: number | null) => {
    setSelectedYear(year);
  }, []);

  const getSelectedVehicle = useCallback((): SelectedVehicle | null => {
    if (!selectedMakeId || !selectedModelId) return null;
    const make = makes?.find(m => m.id === selectedMakeId);
    const model = models?.find(m => m.id === selectedModelId);
    if (!make || !model) return null;
    return {
      makeId: selectedMakeId,
      makeName: make.name,
      modelId: selectedModelId,
      modelName: model.name,
      year: selectedYear ?? undefined,
    };
  }, [selectedMakeId, selectedModelId, selectedYear, makes, models]);

  const reset = useCallback(() => {
    setSelectedMakeId(null);
    setSelectedModelId(null);
    setSelectedYear(null);
  }, []);

  return {
    makes,
    models,
    years,
    selectedMakeId,
    selectedModelId,
    selectedYear,
    makesLoading,
    modelsLoading,
    yearsLoading,
    makesError,
    handleMakeChange,
    handleModelChange,
    handleYearChange,
    getSelectedVehicle,
    reset,
  };
}

export function useLocalStorage<T>(key: string, initialValue: T) {
  const [storedValue, setStoredValue] = useState<T>(() => {
    try {
      const item = window.localStorage.getItem(key);
      return item ? JSON.parse(item) : initialValue;
    } catch {
      return initialValue;
    }
  });

  const setValue = useCallback((value: T | ((val: T) => T)) => {
    try {
      const valueToStore = value instanceof Function ? value(storedValue) : value;
      setStoredValue(valueToStore);
      window.localStorage.setItem(key, JSON.stringify(valueToStore));
    } catch (error) {
      console.error('Error saving to localStorage:', error);
    }
  }, [key, storedValue]);

  return [storedValue, setValue] as const;
}

export function useRecentSearches() {
  const [searches, setSearches] = useLocalStorage<SelectedVehicle[]>('recentSearches', []);

  const addSearch = useCallback((vehicle: SelectedVehicle) => {
    setSearches(prev => {
      const filtered = prev.filter(
        v => !(v.makeId === vehicle.makeId && v.modelId === vehicle.modelId && v.year === vehicle.year)
      );
      return [vehicle, ...filtered].slice(0, 5);
    });
  }, [setSearches]);

  const clearSearches = useCallback(() => {
    setSearches([]);
  }, [setSearches]);

  return { searches, addSearch, clearSearches };
}
