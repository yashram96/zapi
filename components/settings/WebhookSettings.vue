<template>
  <div class="p-6">
    <div class="flex items-center justify-between">
      <h2 class="text-lg font-medium">Webhooks</h2>
      <button
        @click="showNewWebhookModal = true"
        class="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90"
      >
        Add Webhook
      </button>
    </div>
    <div class="mt-4 space-y-4">
      <div v-for="webhook in webhooks" :key="webhook.id" class="rounded-lg border p-4">
        <div class="flex items-center justify-between">
          <div>
            <h3 class="font-medium">{{ webhook.url }}</h3>
            <div class="mt-2 flex flex-wrap gap-2">
              <span
                v-for="event in webhook.events"
                :key="event"
                class="rounded-full bg-primary/10 px-2 py-1 text-xs font-medium text-primary"
              >
                {{ event }}
              </span>
            </div>
          </div>
          <div class="flex items-center space-x-2">
            <button
              @click="$emit('toggle', webhook)"
              :class="[
                'rounded-full p-2',
                webhook.active ? 'text-green-600' : 'text-muted-foreground'
              ]"
            >
              <Icon
                :name="webhook.active ? 'heroicons:check-circle' : 'heroicons:x-circle'"
                class="h-5 w-5"
              />
            </button>
            <button
              @click="$emit('delete', webhook.id)"
              class="rounded-md p-2 text-destructive hover:bg-destructive/10"
            >
              <Icon name="heroicons:trash" class="h-5 w-5" />
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- New Webhook Modal -->
    <div v-if="showNewWebhookModal" class="fixed inset-0 z-50 flex items-center justify-center bg-background/80">
      <div class="w-full max-w-md rounded-lg border bg-card p-6">
        <h3 class="text-lg font-medium">Add Webhook</h3>
        <form @submit.prevent="handleSubmit" class="mt-4 space-y-4">
          <div>
            <label class="block text-sm font-medium mb-1">Webhook URL</label>
            <input
              v-model="form.url"
              type="url"
              class="w-full rounded-lg border bg-background px-3 py-2"
              required
            />
          </div>

          <div>
            <label class="block text-sm font-medium mb-1">Events</label>
            <div class="space-y-2">
              <div v-for="event in availableEvents" :key="event.value" class="flex items-center">
                <input
                  type="checkbox"
                  :id="event.value"
                  v-model="form.events"
                  :value="event.value"
                  class="rounded border-input mr-2"
                />
                <label :for="event.value">{{ event.label }}</label>
              </div>
            </div>
          </div>

          <div class="flex justify-end space-x-2">
            <button
              type="button"
              @click="showNewWebhookModal = false"
              class="rounded-lg border px-4 py-2 text-sm font-medium hover:bg-muted"
            >
              Cancel
            </button>
            <button
              type="submit"
              class="rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90"
            >
              Add Webhook
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const showNewWebhookModal = ref(false)
const form = reactive({
  url: '',
  events: [] as string[]
})

defineProps<{
  webhooks: any[]
  availableEvents: Array<{
    value: string
    label: string
  }>
}>()

const emit = defineEmits<{
  create: [form: typeof form]
  toggle: [webhook: any]
  delete: [id: string]
}>()

const handleSubmit = () => {
  emit('create', { ...form })
  showNewWebhookModal.value = false
  form.url = ''
  form.events = []
}
</script>