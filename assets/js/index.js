
import { Router } from './router.js'

const router = new Router()
router.add("/criar-conta", "/criar-conta.html")
router.add("/login", "/login.html")
router.add("/esqueci-senha", "/pages/esqueci-senha.html")
router.add("/nova-senha", "/pages/nova-senha.html")
router.add("/pin-seguranca", "/pages/pin-seguranca.html")
router.add(404, "/pages/404.html")


router.handle()

window.onpopstate = () => router.handle()
window.route = () => router.route()