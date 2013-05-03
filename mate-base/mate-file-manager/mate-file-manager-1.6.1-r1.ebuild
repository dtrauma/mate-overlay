# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="5"
GCONF_DEBUG="yes"
MATE_LA_PUNT="yes"

inherit mate

DESCRIPTION="Caja file manager for the MATE desktop"
HOMEPAGE="http://mate-desktop.org"

LICENSE="GPL-2 LGPL-2 FDL-1.1"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE="-gtk3 mate +introspection xmp"

RDEPEND=">=dev-libs/glib-2.28.0:2
	gtk3? ( x11-libs/gtk+:3 )
	!gtk3? ( x11-libs/gtk+:2 )
	>=mate-base/mate-desktop-1.5.0
	>=x11-libs/pango-1.1.2
	x11-libs/gtk+:2[introspection?]
	>=dev-libs/libxml2-2.4.7:2
	>=media-libs/libexif-0.5.12
	dev-libs/libunique:1
	x11-libs/libXext
	x11-libs/libXrender
	introspection? ( >=dev-libs/gobject-introspection-0.6.4 )
	xmp? ( media-libs/exempi:2 )"
DEPEND="${RDEPEND}
	>=dev-lang/perl-5
	sys-devel/gettext
	virtual/pkgconfig
	dev-util/gdbus-codegen
	>=dev-util/intltool-0.40.1
	>=mate-base/mate-common-1.2.2"
PDEPEND="mate? ( >=x11-themes/mate-icon-theme-1.2.0 )"

pkg_setup() {
	G2CONF="${G2CONF}
		--disable-update-mimedb
		--disable-packagekit
		--enable-unique
		$(use_enable introspection)
		$(use_enable xmp)"
	DOCS="AUTHORS ChangeLog* HACKING MAINTAINERS NEWS README THANKS TODO"
}

src_prepare() {
	mate_src_prepare

	# Remove crazy CFLAGS
	sed -i \
		-e 's:-DG.*DISABLE_DEPRECATED::g' \
		configure{,.ac} eel/Makefile.{am,in} || die
	
	# Fix default sort order in preferences window gh issue 106
	# https://github.com/mate-desktop/mate-file-manager/issues/106
	sed -i \
		-e '/"manually"/d' \
		src/caja-file-management-properties.c || die

	# Fix radio button in the caja prefferences
	epatch ${FILESDIR}/${P}-preferences-fix.patch
}

src_test() {
	addpredict "/root/.gnome2_private"
	unset SESSION_MANAGER
	unset MATECORBA_SOCKETDIR
	unset DBUS_SESSION_BUS_ADDRESS
	Xemake check || die "Test phase failed"
}

pkg_postinst() {
	mate_pkg_postinst

	elog "caja can use gstreamer to preview audio files. Just make sure"
	elog "to have the necessary plugins available to play the media type you"
	elog "want to preview"
}
