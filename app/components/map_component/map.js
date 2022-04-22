import 'leaflet';
import 'leaflet.markercluster/dist/leaflet.markercluster';

import { Controller } from '@hotwired/stimulus';

import './map.scss';

const MapController = class extends Controller {
  static targets = ['markersTextList', 'marker'];

  connect() {
    const singleMarker = this.markerTargets.length <= 1;
    const polygonData = this.element.dataset.polygon ? JSON.parse(this.element.dataset.polygon) : [];

    if (!singleMarker) {
      this.createCluster();
    }

    this.markerTargets.forEach((marker, index) => {
      const point = {
        lat: marker.dataset.lat,
        lon: marker.dataset.lon,
      };

      if (index === 0) {
        this.create(point, this.element.dataset.zoom);

        polygonData.forEach((polygon) => {
          const polygonLayer = MapController.createPolygon({ coordinates: polygon });
          this.addMapLayer(polygonLayer);
        });
      }

      const leafletMarker = MapController.createMarker(point, marker, index, singleMarker);

      if (!singleMarker) {
        this.addMarkerToCluster(leafletMarker);
      } else if (leafletMarker) {
        leafletMarker.addTo(this.map);
        leafletMarker.openPopup();
      }
    });

    if (!singleMarker) {
      this.addMapLayer(this.clusterGroup);
    }

    if (this.markerTargets.length > 1) {
      this.setMapBounds();
    }
  }

  create(point, zoom) {
    this.map = L.map('map', { tap: false }).setView(point, zoom);

    L.tileLayer(
      'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
      { attribution: 'Map data &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors' },
    ).addTo(this.map);
  }

  createCluster() {
    this.clusterGroup = L.markerClusterGroup({
      iconCreateFunction: (cluster) => {
        const properties = MapController.clusterIconProperties(cluster.getChildCount(), [5, 20]);

        return L.divIcon({
          className: `map-component__map__cluster map-component__map__cluster--${properties.style}`,
          iconSize: [properties.size, properties.size],
          html: `<span>${properties.text}<span class="govuk-visually-hidden">vacancies</span></span>`,
        });
      },
      maxClusterRadius: 32,
    });
  }

  static clusterIconProperties(numberMarkers, thresholds = []) {
    const properties = {
      text: numberMarkers,
      size: 30,
      style: 'default',
    };

    const styles = ['medium', 'large'];

    thresholds.forEach((threshold, i) => {
      if (numberMarkers >= threshold) {
        properties.text = `${threshold}+`;
        properties.style = styles[i];
      }
    });

    return properties;
  }

  addMapLayer(layer) {
    this.map.addLayer(layer);
  }

  addMarkerToCluster(marker) {
    this.clusterGroup.addLayer(marker);
  }

  setMapBounds() {
    this.map.fitBounds(
      this.markerTargets.map((m) => ({ lat: m.dataset.lat, lon: m.dataset.lon })),
    );
  }

  static createPolygon({ coordinates }) {
    return L.polygon(coordinates.map((point) => point.reverse()), { color: '#0b0c0c', weight: 1, smoothFactor: 2 });
  }

  static createMarker(point, marker) {
    const popupHTML = marker.querySelector('.pop-up');
    popupHTML.parentNode.removeChild(popupHTML);
    popupHTML.hidden = false;

    const markerTitle = popupHTML.querySelector('.marker-title').textContent;

    const leafletMarker = L.marker(point, {
      icon: MapController.markerIcon(markerTitle),
      riseOnHover: true,
    });

    leafletMarker.bindPopup(
      popupHTML.outerHTML,
      { className: 'map-component__map__popup' },
    );

    leafletMarker.on('keydown', MapController.closeMarkerPopup);

    return leafletMarker;
  }

  static markerIcon(title) {
    return L.divIcon({
      className: 'icon icon--map-pin',
      iconSize: [22, 30],
      html: `<span class="govuk-visually-hidden">${title}</span>`,
    });
  }

  static closeMarkerPopup(e) {
    e.target.closePopup();
  }
};

export default MapController;
