# Utilisez une image officielle Node.js
FROM node:lts

# Définissez le répertoire de travail dans le conteneur
WORKDIR /app

# Copiez uniquement le contenu de src/ dans le répertoire de travail du conteneur
COPY src/ /app/

# Exposez le port 80 pour l'application
EXPOSE 80

# Commande pour démarrer l'application
CMD ["node", "app.js"]