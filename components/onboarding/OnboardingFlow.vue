<template>
  <div class="mx-auto max-w-xl">
    <div class="mb-8">
      <!-- Progress bar -->
      <div class="relative pt-1">
        <div class="h-2 rounded-full bg-muted">
          <div
            class="h-2 rounded-full bg-primary transition-all duration-300"
            :style="{ width: `${((currentStep + 1) / totalSteps) * 100}%` }"
          ></div>
        </div>
        <div class="mt-2 text-right text-sm text-muted-foreground">
          Step {{ currentStep + 1 }} of {{ totalSteps }}
        </div>
      </div>
    </div>

    <!-- Step content -->
    <TransitionGroup name="slide">
      <div v-if="currentStep === 0" key="step1" class="space-y-6">
        <h2 class="text-2xl font-semibold">Let's get to know you 👋</h2>
        
        <div class="space-y-4">
          <div>
            <label class="mb-2 block text-sm font-medium">What should we call you?</label>
            <input
              v-model="formData.displayName"
              type="text"
              class="w-full rounded-lg border bg-background px-4 py-2"
              placeholder="Your name"
              required
            />
          </div>

          <div>
            <label class="mb-2 block text-sm font-medium">Your role in the team?</label>
            <select
              v-model="formData.role"
              class="w-full rounded-lg border bg-background px-4 py-2"
              required
            >
              <option value="" disabled>Select your role</option>
              <option value="frontend_developer">Frontend Developer</option>
              <option value="full_stack_developer">Full Stack Developer</option>
              <option value="qa_tester">QA / Tester</option>
              <option value="designer">Designer</option>
              <option value="product_manager">Product Manager</option>
              <option value="other">Other</option>
            </select>
          </div>
        </div>
      </div>

      <div v-if="currentStep === 1" key="step2" class="space-y-6">
        <h2 class="text-2xl font-semibold">What brings you to Zapi?</h2>
        
        <div class="space-y-3">
          <label
            v-for="useCase in useCases"
            :key="useCase.value"
            class="flex cursor-pointer items-center space-x-3 rounded-lg border p-4 hover:bg-muted/50"
          >
            <input
              type="checkbox"
              :value="useCase.value"
              v-model="formData.useCases"
              class="rounded border-input"
            />
            <span>{{ useCase.label }}</span>
          </label>
        </div>
      </div>

      <div v-if="currentStep === 2" key="step3" class="space-y-6">
        <h2 class="text-2xl font-semibold">Are you flying solo or with a squad?</h2>
        
        <div class="space-y-3">
          <label
            v-for="size in teamSizes"
            :key="size.value"
            class="flex cursor-pointer items-center space-x-3 rounded-lg border p-4 hover:bg-muted/50"
            :class="{ 'bg-primary/10 border-primary': formData.teamSize === size.value }"
          >
            <input
              type="radio"
              :value="size.value"
              v-model="formData.teamSize"
              name="teamSize"
              class="rounded border-input"
            />
            <div>
              <p class="font-medium">{{ size.label }}</p>
              <p class="text-sm text-muted-foreground">{{ size.description }}</p>
            </div>
          </label>
        </div>
      </div>
    </TransitionGroup>

    <!-- Navigation -->
    <div class="mt-8 flex justify-between">
      <button
        v-if="currentStep > 0"
        @click="currentStep--"
        class="rounded-lg border px-4 py-2 text-sm font-medium hover:bg-muted"
      >
        Back
      </button>
      <button
        v-if="currentStep < totalSteps - 1"
        @click="nextStep"
        class="ml-auto rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90"
      >
        Continue
      </button>
      <button
        v-else
        @click="complete"
        class="ml-auto rounded-lg bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90"
      >
        Complete Setup
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
const { supabase } = useSupabase()
const router = useRouter()

const currentStep = ref(0)
const totalSteps = 3

const formData = ref({
  displayName: '',
  role: '',
  useCases: [] as string[],
  teamSize: ''
})

const useCases = [
  { value: 'frontend_first', label: '🔧 Build frontend before backend is ready' },
  { value: 'testing', label: '🧪 Test APIs and simulate errors' },
  { value: 'internal_tools', label: '🖥️ Create mock servers for internal tools' },
  { value: 'education', label: '🧑‍🏫 Educate/train others' },
  { value: 'experimentation', label: '🎭 Experiment with ideas' }
]

const teamSizes = [
  { value: 'solo', label: 'Just me', description: 'Working on personal or freelance projects' },
  { value: 'small_team', label: 'Small team (2-5 people)', description: 'Tight-knit group working closely together' },
  { value: 'growing_team', label: 'Growing team (6-20)', description: 'Scaling up with multiple projects' },
  { value: 'large_team', label: 'Large team (20+)', description: 'Enterprise-level organization' }
]

const nextStep = () => {
  if (currentStep.value < totalSteps - 1) {
    currentStep.value++
  }
}

const complete = async () => {
  try {
    const { data: { user } } = await supabase.auth.getUser()
    if (!user) throw new Error('No user found')

    const { error } = await supabase
      .from('profiles')
      .update({
        display_name: formData.value.displayName,
        role: formData.value.role,
        use_cases: formData.value.useCases,
        team_size: formData.value.teamSize,
        onboarding_completed: true
      })
      .eq('id', user.id)

    if (error) throw error

    // Redirect to dashboard
    router.push('/dashboard')
  } catch (error) {
    console.error('Error saving onboarding data:', error)
  }
}
</script>

<style scoped>
.slide-enter-active,
.slide-leave-active {
  transition: all 0.3s ease;
}

.slide-enter-from {
  opacity: 0;
  transform: translateX(30px);
}

.slide-leave-to {
  opacity: 0;
  transform: translateX(-30px);
}
</style>