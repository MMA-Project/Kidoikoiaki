import { useState } from "react";
import { motion } from "framer-motion";
import { useCreateExpense } from "../api/hooks";
import type { Participant } from "../types";

interface ExpenseFormProps {
  listId: string;
  participants: Participant[];
  onSuccess: () => void;
  onCancel: () => void;
}

export default function ExpenseForm({
  listId,
  participants,
  onSuccess,
  onCancel,
}: ExpenseFormProps) {
  const createExpenseMutation = useCreateExpense();

  const [title, setTitle] = useState("");
  const [amount, setAmount] = useState("");
  const [payerId, setPayerId] = useState("");
  const [selectedParticipants, setSelectedParticipants] = useState<string[]>(
    [],
  );
  const [image, setImage] = useState<File | null>(null);
  const [imagePreview, setImagePreview] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  function handleImageChange(e: React.ChangeEvent<HTMLInputElement>) {
    const file = e.target.files?.[0];
    if (file) {
      setImage(file);
      const reader = new FileReader();
      reader.onloadend = () => {
        setImagePreview(reader.result as string);
      };
      reader.readAsDataURL(file);
    }
  }

  function handleSelectAll() {
    if (selectedParticipants.length === participants.length) {
      setSelectedParticipants([]);
    } else {
      setSelectedParticipants(participants.map((p) => p.id));
    }
  }

  function toggleParticipant(id: string) {
    if (selectedParticipants.includes(id)) {
      setSelectedParticipants(selectedParticipants.filter((p) => p !== id));
    } else {
      setSelectedParticipants([...selectedParticipants, id]);
    }
  }

  async function handleSubmit(e: React.FormEvent) {
    e.preventDefault();
    setError(null);

    if (!title.trim()) {
      setError("Le titre est requis");
      return;
    }
    if (!amount || parseFloat(amount) <= 0) {
      setError("Le montant doit être positif");
      return;
    }
    if (!payerId) {
      setError("Veuillez sélectionner qui a payé");
      return;
    }
    if (selectedParticipants.length === 0) {
      setError("Veuillez sélectionner au moins un participant");
      return;
    }

    try {
      await createExpenseMutation.mutateAsync({
        listId,
        title: title.trim(),
        amount: parseFloat(amount),
        payerId,
        participantIds: selectedParticipants,
        image: image || undefined,
      });
      onSuccess();
    } catch (err) {
      setError(
        err instanceof Error ? err.message : "Erreur lors de la création",
      );
    }
  }

  return (
    <motion.form
      initial={{ opacity: 0, height: 0 }}
      animate={{ opacity: 1, height: "auto" }}
      exit={{ opacity: 0, height: 0 }}
      onSubmit={handleSubmit}
      className="bg-linear-to-r from-indigo-50 to-purple-50 rounded-xl p-6 mb-6 overflow-hidden"
    >
      <h3 className="text-lg font-semibold text-slate-800 mb-4">
        Nouvelle dépense
      </h3>

      {error && (
        <motion.div
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          className="bg-red-50 border border-red-200 text-red-600 px-4 py-2 rounded-lg mb-4 text-sm"
        >
          {error}
        </motion.div>
      )}

      <div className="space-y-4">
        {/* Title */}
        <div>
          <label
            htmlFor="title"
            className="block text-sm font-medium text-slate-700 mb-1"
          >
            Titre *
          </label>
          <input
            id="title"
            type="text"
            value={title}
            onChange={(e) => setTitle(e.target.value)}
            placeholder="Ex: Restaurant, Essence, Courses..."
            disabled={createExpenseMutation.isPending}
            className="w-full px-4 py-3 bg-white border border-slate-200 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-transparent outline-none transition-all text-slate-800 placeholder:text-slate-400"
          />
        </div>

        {/* Amount */}
        <div>
          <label
            htmlFor="amount"
            className="block text-sm font-medium text-slate-700 mb-1"
          >
            Montant (€) *
          </label>
          <input
            id="amount"
            type="number"
            step="0.01"
            min="0.01"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            placeholder="0.00"
            disabled={createExpenseMutation.isPending}
            className="w-full px-4 py-3 bg-white border border-slate-200 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-transparent outline-none transition-all text-slate-800 placeholder:text-slate-400"
          />
        </div>

        {/* Payer */}
        <div>
          <label
            htmlFor="payer"
            className="block text-sm font-medium text-slate-700 mb-1"
          >
            Payé par *
          </label>
          <select
            id="payer"
            value={payerId}
            onChange={(e) => setPayerId(e.target.value)}
            disabled={createExpenseMutation.isPending}
            className="w-full px-4 py-3 bg-white border border-slate-200 rounded-xl focus:ring-2 focus:ring-indigo-500 focus:border-transparent outline-none transition-all text-slate-800"
          >
            <option value="">-- Sélectionner --</option>
            {participants.map((p) => (
              <option key={p.id} value={p.id}>
                {p.name}
              </option>
            ))}
          </select>
        </div>

        {/* Participants */}
        <div>
          <label className="block text-sm font-medium text-slate-700 mb-2">
            Pour qui ? *
          </label>
          <div className="bg-white border border-slate-200 rounded-xl p-4">
            <button
              type="button"
              onClick={handleSelectAll}
              className="text-indigo-600 text-sm font-medium hover:text-indigo-800 transition-colors mb-3"
            >
              {selectedParticipants.length === participants.length
                ? "Désélectionner tout"
                : "Sélectionner tout"}
            </button>
            <div className="flex flex-wrap gap-3">
              {participants.map((p) => (
                <label
                  key={p.id}
                  className={`flex items-center gap-2 px-3 py-2 rounded-lg cursor-pointer transition-all ${
                    selectedParticipants.includes(p.id)
                      ? "bg-indigo-100 text-indigo-700"
                      : "bg-slate-50 text-slate-600 hover:bg-slate-100"
                  }`}
                >
                  <input
                    type="checkbox"
                    checked={selectedParticipants.includes(p.id)}
                    onChange={() => toggleParticipant(p.id)}
                    disabled={createExpenseMutation.isPending}
                    className="sr-only"
                  />
                  <span
                    className={`w-4 h-4 rounded border-2 flex items-center justify-center ${
                      selectedParticipants.includes(p.id)
                        ? "bg-indigo-600 border-indigo-600"
                        : "border-slate-300"
                    }`}
                  >
                    {selectedParticipants.includes(p.id) && (
                      <span className="text-white text-xs">✓</span>
                    )}
                  </span>
                  {p.name}
                </label>
              ))}
            </div>
          </div>
        </div>

        {/* Image Upload */}
        <div>
          <label
            htmlFor="image"
            className="block text-sm font-medium text-slate-700 mb-1"
          >
            Photo du reçu (optionnel)
          </label>
          <input
            id="image"
            type="file"
            accept="image/*"
            onChange={handleImageChange}
            disabled={createExpenseMutation.isPending}
            className="w-full px-4 py-3 bg-white border border-dashed border-slate-300 rounded-xl file:mr-4 file:py-2 file:px-4 file:rounded-lg file:border-0 file:bg-indigo-50 file:text-indigo-700 file:font-medium hover:file:bg-indigo-100 transition-all"
          />
          {imagePreview && (
            <div className="relative mt-3 inline-block">
              <img
                src={imagePreview}
                alt="Aperçu"
                className="max-w-48 max-h-32 rounded-lg object-cover"
              />
              <button
                type="button"
                onClick={() => {
                  setImage(null);
                  setImagePreview(null);
                }}
                className="absolute -top-2 -right-2 w-6 h-6 bg-red-500 text-white rounded-full flex items-center justify-center hover:bg-red-600 transition-colors"
              >
                ×
              </button>
            </div>
          )}
        </div>

        {/* Actions */}
        <div className="flex gap-3 pt-2">
          <motion.button
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
            type="button"
            onClick={onCancel}
            disabled={createExpenseMutation.isPending}
            className="flex-1 px-4 py-3 bg-white text-slate-700 rounded-xl font-medium hover:bg-slate-50 transition-colors"
          >
            Annuler
          </motion.button>
          <motion.button
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
            type="submit"
            disabled={createExpenseMutation.isPending}
            className="flex-1 px-4 py-3 bg-indigo-600 text-white rounded-xl font-medium hover:bg-indigo-700 disabled:bg-indigo-300 transition-colors"
          >
            {createExpenseMutation.isPending ? "Création..." : "Ajouter"}
          </motion.button>
        </div>
      </div>
    </motion.form>
  );
}
