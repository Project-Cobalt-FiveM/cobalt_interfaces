<script lang="ts">
  import AlertDialog from './components/AlertDialog.svelte';
  import ContextMenu from './components/ContextMenu.svelte';
  import IdCard from './components/IdCard.svelte';
  import InputDialog from './components/InputDialog.svelte';
  import Notifications from './components/Notifications.svelte';
  import Progress from './components/Progress.svelte';
  import RadialMenu from './components/RadialMenu.svelte';
  import SkillCheck from './components/SkillCheck.svelte';
  import TextUI from './components/TextUI.svelte';
</script>

<main class="relative h-screen w-screen overflow-hidden font-sans">
  <Notifications />
  <TextUI />
  <Progress />
  <SkillCheck />
  <ContextMenu />
  <RadialMenu />
  <InputDialog />
  <AlertDialog />
  <IdCard />
</main>
