<template>
  <div class='home'>
    <h1>Agile Season</h1>
    <h2>Kanban board for GitHub issues</h2>
    <a :href='signInUrl'>Sign in with GitHub</a>
  </div>
</template>

<script>
// @ is an alias to /src
// import HelloWorld from '@/components/HelloWorld.vue'

export default {
  name: 'Home',
  components: {
  },
  data() {
    return {};
  },
  computed: {
    signInUrl() {
      return `${process.env.VUE_APP_API_URL}/oauth`;
    }
  }
  // mounted() {
  //   console.log(process.env.VUE_APP_GITHUB_CLIENT_ID)
  //   console.log(process.env.VUE_APP_GITHUB_CLIENT_SECRET)
  // }
}
</script>
