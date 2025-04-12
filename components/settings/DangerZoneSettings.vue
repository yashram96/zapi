<template>
  <div>
    <h2 class="text-lg font-medium text-destructive">Danger Zone</h2>
    <p class="mt-1 text-sm text-muted-foreground">
      These actions are destructive and cannot be undone. Please proceed with caution.
    </p>

    <div class="mt-4 space-y-4">
      <!-- Transfer Ownership -->
      <div class="rounded-lg border border-destructive/20 p-4">
        <h3 class="font-medium">Transfer Organization Ownership</h3>
        <p class="mt-1 text-sm text-muted-foreground">
          Transfer ownership of this organization to another admin
        </p>
        <button
          @click="showTransferModal = true"
          class="mt-4 rounded-lg border border-destructive px-4 py-2 text-sm font-medium text-destructive hover:bg-destructive/10"
        >
          Transfer Ownership
        </button>
      </div>

      <!-- Delete Organization -->
      <div class="rounded-lg border border-destructive/20 p-4">
        <h3 class="font-medium">Delete Organization</h3>
        <p class="mt-1 text-sm text-muted-foreground">
          Permanently delete this organization and all its data
        </p>
        <button
          @click="showDeleteModal = true"
          class="mt-4 rounded-lg bg-destructive px-4 py-2 text-sm font-medium text-destructive-foreground hover:bg-destructive/90"
        >
          Delete Organization
        </button>
      </div>
    </div>

    <!-- Transfer Ownership Modal -->
    <div v-if="showTransferModal" class="fixed inset-0 z-50 flex items-center justify-center bg-background/80">
      <div class="w-full max-w-md rounded-lg border bg-card p-6">
        <h3 class="text-lg font-medium">Transfer Organization Ownership</h3>
        <p class="mt-2 text-sm text-muted-foreground">
          Please type the organization name to confirm transfer
        </p>

        <input
          v-model="confirmTransferName"
          type="text"
          class="mt-4 w-full rounded-lg border bg-background px-3 py-2"
          :placeholder="organization?.name"
        />

        <div class="mt-6 flex justify-end space-x-2">
          <button
            @click="showTransferModal = false"
            class="rounded-lg border px-4 py-2 text-sm font-medium hover:bg-muted"
          >
            Cancel
          </button>
          <button
            @click="handleTransfer"
            :disabled="confirmTransferName !== organization?.name"
            class="rounded-lg bg-destructive px-4 py-2 text-sm font-medium text-destructive-foreground hover:bg-destructive/90 disabled:opacity-50"
          >
            Transfer
          </button>
        </div>
      </div>
    </div>

    <!-- Delete Organization Modal -->
    <div v-if="showDeleteModal" class="fixed inset-0 z-50 flex items-center justify-center bg-background/80">
      <div class="w-full max-w-md rounded-lg border bg-card p-6">
        <h3 class="text-lg font-medium">Delete Organization</h3>
        <p class="mt-2 text-sm text-muted-foreground">
          This action cannot be undone. Please type the organization name to confirm deletion.
        </p>

        <input
          v-model="confirmDeleteName"
          type="text"
          class="mt-4 w-full rounded-lg border bg-background px-3 py-2"
          :placeholder="organization?.name"
        />

        <div class="mt-6 flex justify-end space-x-2">
          <button
            @click="showDeleteModal = false"
            class="rounded-lg border px-4 py-2 text-sm font-medium hover:bg-muted"
          >
            Cancel
          </button>
          <button
            @click="handleDelete"
            :disabled="confirmDeleteName !== organization?.name"
            class="rounded-lg bg-destructive px-4 py-2 text-sm font-medium text-destructive-foreground hover:bg-destructive/90 disabled:opacity-50"
          >
            Delete Organization
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{
  organization: any
}>()

const showTransferModal = ref(false)
const showDeleteModal = ref(false)
const confirmTransferName = ref('')
const confirmDeleteName = ref('')

const emit = defineEmits<{
  'delete-organization': []
  'transfer-ownership': [newOwnerId: string]
}>()

const handleDelete = () => {
  if (confirmDeleteName.value === props.organization?.name) {
    emit('delete-organization')
    showDeleteModal.value = false
    confirmDeleteName.value = ''
  }
}

const handleTransfer = () => {
  if (confirmTransferName.value === props.organization?.name) {
    // TODO: Implement transfer logic
    showTransferModal.value = false
    confirmTransferName.value = ''
  }
}
</script>